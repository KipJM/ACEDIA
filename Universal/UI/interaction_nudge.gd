extends Control

@export
var ui_base: Control

@export
var interactionNodes: Array[Control]

#var permanent_hidden: bool = false

func _ready() -> void:
	set_ui(false)

func _process(delta: float) -> void:
	#if not permanent_hidden:
	if ui_base.Player != null:
		set_ui(ui_base.Player.IsInteractionHovering)
	else:
		set_ui(false)
#func on_interaction() -> void:
	#permanent_hidden = true
	#set_ui(false)

func set_ui(visibility: bool) -> void:
	for ui in interactionNodes:
		ui.visible = visibility
