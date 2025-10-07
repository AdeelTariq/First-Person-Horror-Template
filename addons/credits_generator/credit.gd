class_name Credit extends RefCounted
var category: String
var sub_category: String
var package_name: String
var path: String
var author: String
var author_link: String
var license: String
var license_link: String
var package_link: String

func _to_string() -> String:
		return "Credit(
		Category: %s, 
		Sub-Category: %s, 
		Package: %s, 
		Path: %s, 
		Author: %s,
		License: %s,
		License Link: %s,
		Package Link: %s)\n\n" % [
			category, sub_category, package_name, path, author, license, license_link, package_link
		]
