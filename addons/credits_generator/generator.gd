class_name Generator extends RefCounted

var license_file_name: String = "LICENSE.md"
var auto_generated_keyword: String = "[](AUTO_GENERATED)"

func generate():
	var base_dir = get_plugin_path()
	var layout_path = base_dir.path_join("LAYOUT.md")
	var credits_path = "res://CREDITS.md"

	var layout_content = read_file(layout_path)
	if layout_content == "":
		printerr(layout_path + " is empty or missing")
		return

	var pattern = r"\[\]\(([^)]+\.md)\)"
	var regex = RegEx.new()
	regex.compile(pattern)

	var result = layout_content
	for match in regex.search_all(layout_content):
		var md_filename = match.get_string(1)
		var md_path = md_filename if md_filename.begins_with("res://") else base_dir.path_join(md_filename)
		var md_content = read_file(md_path)
		if md_content == "":
			md_content = "[Missing file: %s]" % md_filename
		result = result.replace(match.get_string(0), md_content)

	var paths: Array[String] = find_files_by_name(license_file_name)
	var credits: Array[Credit] = create_credits_from_paths(paths)
	var grouped: Dictionary[String, Dictionary] = group_credits(credits)
	var auto_generated: String = ""
	var sorted_categories: Array = grouped.keys()
	sorted_categories.sort()
	for category in sorted_categories:
		auto_generated += "### %s\n" % category
		var sorted_subs: Array = grouped[category].keys()
		sorted_subs.sort()
		for sub: String in sorted_subs:
			if sub != "":
				auto_generated += "#### %s\n" % sub
			for credit: Credit in grouped[category][sub]:
				auto_generated += "##### [%s](%s)\n" % [credit.package_name, credit.package_link]
				auto_generated += "Author: %s  \n" % credit.author
				auto_generated += "License: [%s](%s)  \n\n" % [credit.license, credit.license_link]

	result = result.replace(auto_generated_keyword, auto_generated)
	result = remove_comments(result)
	write_file(credits_path, result)
	EditorInterface.get_resource_filesystem().scan()
	print("CREDITS.md generated successfully")


func read_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var f = FileAccess.open(path, FileAccess.READ)
	return f.get_as_text()


func write_file(path: String, content: String) -> void:
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(content)
	f.close()


func get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir() + "/"


func remove_comments(text: String) -> String:
	var comment_regex = RegEx.new()
	comment_regex.compile("(?s)<!--.*?-->")
	return comment_regex.sub(text, "", true)


func find_files_by_name(target_name: String, start_dir: String = "res://") -> Array[String]:
	var results: Array[String] = []
	var dir = DirAccess.open(start_dir)
	if dir == null:
		return results

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if file_name != "." and file_name != "..":
				results += find_files_by_name(target_name, start_dir.path_join(file_name))
		elif file_name == target_name:
			results.append(start_dir.path_join(file_name))
		file_name = dir.get_next()

	dir.list_dir_end()
	return results


func create_credits_from_paths(paths: Array[String]) -> Array:
	var credits: Array[Credit] = []
	for path in paths:
		var parts = path.replace("res://", "").split("/")
		if parts.size() < 2:
			continue

		var credit = Credit.new()
		credit.path = path
		var metadata: Array[String] = get_metadata(path)
		credit.author = metadata[0]
		credit.license = metadata[1]
		credit.license_link = metadata[2]
		credit.package_link = metadata[3]

		# Determine category
		credit.category = parts[0].capitalize()
		credit.package_name = parts[-2].capitalize()

		# Determine sub_category and package_name
		if parts[1].capitalize() != credit.package_name and credit.category != "Addons":
			credit.sub_category = parts[1].capitalize()
		elif credit.category == "Addons":
			credit.sub_category = ""
		else:
			credit.sub_category = "Others"

		credits.append(credit)

	return credits


func get_metadata(path: String) -> Array[String]:
	if not FileAccess.file_exists(path):
		return []

	var text = FileAccess.open(path, FileAccess.READ).get_as_text()
	var lines = text.split("\n")
	var name: String = ""
	var license: String = ""
	var website: String = ""
	var license_link: String = ""

	var re_copyright = RegEx.new()
	re_copyright.compile(r"Copyright\s*\(c\)\s*\d{4}(?:-[0-9]+)?(?:-present)?\s*(.*)")

	var re_created = RegEx.new()
	re_created.compile(r"Created.+by\s+([^(]+)")

	var re_license = RegEx.new()
	re_license.compile(r"License:\s+(.+)")

	var re_license_link = RegEx.new()
	re_license_link.compile(r"License Link:\s+([^(]+)")
	
	var re_website = RegEx.new()
	re_website.compile(r"Website:\s+([^(]+)")
	
	for line in lines:
		line = line.strip_edges()
		if line == "":
			continue
		var found = re_copyright.search(line)
		if found:
			name = found.get_string(1).strip_edges()
			continue
		found = re_created.search(line)
		if found and name == "":
			name = found.get_string(1).strip_edges()
			continue
		found = re_license.search(line)
		if found:
			license = found.get_string(1).strip_edges()
			continue
		found = re_license_link.search(line)
		if found:
			license_link = found.get_string(1).strip_edges()
			continue
		found = re_website.search(line)
		if found:
			website = found.get_string(1).strip_edges()
			continue
	return [name, license, license_link, website]


func group_credits(credits: Array[Credit]) -> Dictionary[String, Dictionary]:
	var grouped: Dictionary[String, Dictionary] = {}

	for credit in credits:
		if not grouped.has(credit.category):
			grouped[credit.category] = {}
		if not grouped[credit.category].has(credit.sub_category):
			grouped[credit.category][credit.sub_category] = []
		grouped[credit.category][credit.sub_category].append(credit)

	return grouped
