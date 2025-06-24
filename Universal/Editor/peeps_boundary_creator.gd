@tool
extends Node3D

@export var boundary_prfb: PackedScene

@export_tool_button("Add collision") var run_button = add_collisions

func add_collisions() -> void:
	var childs = get_children()
	for child in childs:
		var inst = boundary_prfb.instantiate()
		child.add_child(inst, true)
		inst.owner = child.get_tree().edited_scene_root
