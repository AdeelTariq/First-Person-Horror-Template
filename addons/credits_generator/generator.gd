class_name Generator extends RefCounted

const license_file_name: String = "LICENSE.md"
const auto_generated_keyword: String = "[](AUTO_GENERATED)"
const godot_license_keyword: String = "[](GODOT_LICENSE)"
const godot_3rd_party_copyright_keyword: String = "[](GODOT_3RD_PARTY_COPYRIGHT)"
const godot_3rd_party_licenses_keyword: String = "[](GODOT_3RD_PARTY_LICENSES)"


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
				auto_generated += "Author: [%s](%s)  \n" % [credit.author, credit.author_link]
				auto_generated += "License: [%s](%s)  \n\n" % [credit.license, credit.license_link]

	result = result.replace(auto_generated_keyword, auto_generated)
	result = result.replace(godot_license_keyword, Engine.get_license_text())
	result = result.replace(godot_3rd_party_copyright_keyword, format_godot_3rd_party_copyright())
	result = result.replace(godot_3rd_party_licenses_keyword, format_godot_3rd_party_licenses())
	
	result = remove_comments(result).strip_edges()
	write_file(credits_path, "\n" + result)
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
		credit = get_metadata(path, credit)

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


static func get_metadata(path: String, credit: Credit) -> Credit:
	if not FileAccess.file_exists(path):
		return credit

	var text = FileAccess.open(path, FileAccess.READ).get_as_text()
	var lines = text.split("\n")
	credit.author = ""
	
	var re_author = RegEx.new()
	re_author.compile(r"Author:\s+([^(]+)")

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
	
	var re_author_link = RegEx.new()
	re_author_link.compile(r"Author Link:\s+([^(]+)")
	
	for line in lines:
		line = line.strip_edges()
		if line == "":
			continue
		var found = re_author.search(line)
		if found and credit.author == "":
			credit.author = found.get_string(1).strip_edges()
			continue
		found = re_copyright.search(line)
		if found and credit.author == "":
			credit.author = found.get_string(1).strip_edges()
			continue
		found = re_created.search(line)
		if found and credit.author == "":
			credit.author = found.get_string(1).strip_edges()
			continue
		found = re_license.search(line)
		if found:
			credit.license = found.get_string(1).strip_edges()
			continue
		found = re_license_link.search(line)
		if found:
			credit.license_link = found.get_string(1).strip_edges()
			continue
		found = re_website.search(line)
		if found:
			credit.package_link = found.get_string(1).strip_edges()
			continue
		found = re_author_link.search(line)
		if found:
			credit.author_link = found.get_string(1).strip_edges()
			continue
	return credit


func group_credits(credits: Array[Credit]) -> Dictionary[String, Dictionary]:
	var grouped: Dictionary[String, Dictionary] = {}

	for credit in credits:
		if not grouped.has(credit.category):
			grouped[credit.category] = {}
		if not grouped[credit.category].has(credit.sub_category):
			grouped[credit.category][credit.sub_category] = []
		grouped[credit.category][credit.sub_category].append(credit)

	return grouped


func format_godot_3rd_party_licenses() -> String:
	var result: String = ""
	var licenses: Dictionary = Engine.get_license_info()
	for license: String in licenses:
		result += "#### %s\n" % license
		result += "%s  \n\n" % licenses[license]
	return result


func format_godot_3rd_party_copyright() -> String:
	var result: String = ""
	for dict: Dictionary in Engine.get_copyright_info():
		result += "#### %s\n" % dict["name"]
		for part: Dictionary in dict["parts"]:
			result += "**Copyright**  \n"
			result += "  \n".join(part["copyright"])
			result += "  \n**License**: %s  \n\n" % part["license"]
	return result
