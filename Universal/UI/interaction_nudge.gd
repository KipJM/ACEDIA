extends Control

@export
var interactionNodes: Array[Control]

var permanent_hidden: bool = false

func _ready() -> void:
	set_ui(false)

func _process(delta: float) -> void:
	if not permanent_hidden:
		set_ui(%Player.IsInteractionHovering)

func on_interaction() -> void:
	permanent_hidden = true
	set_ui(false)

func set_ui(visibility: bool) -> void:
	for ui in interactionNodes:
		ui.visible = visibility
