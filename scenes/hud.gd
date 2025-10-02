extends Control

@onready var cross_hair: TextureRect = %CrossHair
@onready var interact_prompt: RichTextLabel = %InteractPrompt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_nothing_interactable()
	InteractionController.current.clear_action_prompts.connect(_nothing_interactable)
	InteractionController.current.display_action_prompts.connect(_something_interactable)


func _nothing_interactable() -> void:
	cross_hair.hide()
	interact_prompt.text = ""


func _something_interactable(object_name: String, actions: Array[Interaction], _alt_display: bool) -> void:
	cross_hair.show()
	interact_prompt.text = "[b]%s[/b]: %s" % [
		object_name,
		", ".join(actions.map(func(a: Interaction) -> String: return await a.prompt_async()))
	]
