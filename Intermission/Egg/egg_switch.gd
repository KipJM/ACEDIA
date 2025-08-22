extends Node

var egg: bool

@export var egg_node: Node
@export var default_node: Node
@export var debug_egg: bool

func _ready() -> void:
	egg = false
	if GraphicsSettings.new_game_plus:
		egg = true

	#if debug_egg:
		#egg = true

	print("egg: " + str(egg))
	if egg:
		default_node.queue_free()
	else:
		egg_node.queue_free()
