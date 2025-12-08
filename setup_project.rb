#!/usr/bin/env ruby

require 'fileutils'

# Config
EXCLUDE = ['addons', '.git', 'depmap.md', 'depmap.py', 'setup_project.rb', 'todo.txt']  # folders or files to skip
ADDONS_DIR = File.join(Dir.pwd, 'addons')

picker_cmd = 'zenity --file-selection --directory --title="Project Location"'
selected_path = `#{picker_cmd}`.strip

abort("No location selected") if selected_path.empty?

puts "Copying files"
# Copy everything except excluded paths
items = Dir.glob('*', File::FNM_DOTMATCH).reject { |i| ['.', '..'].include?(i) || EXCLUDE.include?(i) }
total = items.size
count = 0

items.each do |item|
  count += 1
  src = File.join(Dir.pwd, item)
  dst = File.join(selected_path, item)

  if File.directory?(src)
    FileUtils.cp_r(src, dst)
  else
    FileUtils.cp(src, dst)
  end

  percent = ((count.to_f / total) * 100).to_i
  print "\rProgress: #{percent}%"
  $stdout.flush
end

puts "\nDone."

# Create symlink: selected_path/addons -> working_dir/addons
if Dir.exist?(ADDONS_DIR)
  link_path = File.join(selected_path, 'addons')
  FileUtils.ln_s(ADDONS_DIR, link_path, force: true)
  puts "Symlink created: #{link_path} -> #{ADDONS_DIR}"
else
  puts "No addons folder found in working directory."
end

# Extract folder name from selected_path and humanize it
parent_folder_name = File.basename(selected_path)
human_name = parent_folder_name.gsub(/[-_]/, ' ').split.map(&:capitalize).join(' ')

# Edit project.godot
project_file = File.join(selected_path, 'project.godot')
if File.exist?(project_file)
  lines = File.read(project_file).split("\n")
  updated = false

  lines.map! do |line|
    if line.start_with?('config/name=')
      updated = true
      "config/name=\"#{human_name}\""
    else
      line
    end
  end

  lines << "config/name=\"#{human_name}\"" unless updated

  File.write(project_file, lines.join("\n"))
  puts "Set project name to: #{human_name}"
end
