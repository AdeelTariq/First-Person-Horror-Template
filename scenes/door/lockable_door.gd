class_name LockableDoor extends Door

var _interacting_controller: InteractionController

func lock_door(controller: InteractionController) -> void:
	var interaction_container: InteractionContainer = InteractionContainer.from(door_body)
	interaction_container.enable(2)
	controller.refresh_prompts(interaction_container)


func unlock_door(controller: InteractionController) -> void:
	var interaction_container: InteractionContainer = InteractionContainer.from(door_body)
	interaction_container.enable(0)
	controller.refresh_prompts(interaction_container)


func interact(controller: InteractionController) -> void:
	super.interact(controller)
	_interacting_controller = controller


func _on_tween_finished() -> void:
	super._on_tween_finished()
	var interaction_container: InteractionContainer = InteractionContainer.from(door_body)
	if is_closed:
		interaction_container.enable(0)
		_interacting_controller.refresh_prompts(interaction_container)
	else:
		interaction_container.enable(1)
		_interacting_controller.refresh_prompts(interaction_container)
