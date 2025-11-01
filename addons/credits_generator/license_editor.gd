@tool
class_name LicenseEditor extends ConfirmationDialog

@onready var author: TextEdit = $VBoxContainer/Author
@onready var author_link: TextEdit = $VBoxContainer/AuthorLink
@onready var license: TextEdit = $VBoxContainer/License
@onready var license_link: TextEdit = $"VBoxContainer/License Link"
@onready var asset_link: TextEdit = $"VBoxContainer/Asset Link"

func show_dialog(path: String) -> void:
	var credits: Credit = Generator.get_metadata(path + "/LICENSE.md", Credit.new())
	author.text = credits.author
	author_link.text = credits.author_link
	license.text = credits.license
	license_link.text = credits.license_link
	asset_link.text = credits.package_link
	
	for conn in confirmed.get_connections():
		confirmed.disconnect(conn["callable"])
	confirmed.connect(save_license.bind(path + "/LICENSE.md"))
	show()


func save_license(path: String) -> void:
	var content: String = \
	"Author: %s
Author Link: %s
License: %s
License Link: %s
Website: %s
	" % [
		author.text,
		author_link.text,
		license.text,
		license_link.text,
		asset_link.text,
	]
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(content)
	f.close()
	EditorInterface.get_resource_filesystem().scan()
