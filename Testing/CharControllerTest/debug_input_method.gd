extends Control

@export var pc_node: TextureRect
@export var ps_node: TextureRect
@export var xbox_node: TextureRect

func _input(event: InputEvent) -> void:
	print(event.device)
