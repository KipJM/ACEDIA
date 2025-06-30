@tool
extends Node3D

@export var boundary_prfb: PackedScene

@export var boundary_center: Node3D
@export var boundary_max: Node3D
@export var radius_curve: Curve

@export_tool_button("Distribute Position") var dist_button = distribute
@export_tool_button("Random Rotate") var rotate_button = rotate_rand
@export_tool_button("Add collision") var run_button = add_collisions

func add_collisions() -> void:
	var childs = get_children()
	for child in childs:
		var inst = boundary_prfb.instantiate()
		child.add_child(inst, true)
		inst.owner = child.get_tree().edited_scene_root


func distribute() -> void:
	var peeps = get_children()
	var rng = RandomNumberGenerator.new()
	
	var max_rad = boundary_max.global_position.distance_to(boundary_center.global_position)
	
	for child in peeps:
		child = child as Node3D
		
		var rad = radius_curve.sample(rng.randf_range(0, 1)) * max_rad
		var ang = rng.randf_range(0, 2*PI)
		
		child.global_position = boundary_center.global_position
		child.global_position.x += sin(ang) * rad
		child.global_position.z += cos(ang) * rad
		
func rotate_rand() -> void:
	var rng = RandomNumberGenerator.new()
	
	for child in get_children():
		child = child as Node3D
		child.rotate_z(rng.randf() * 2 * PI)
		child.rotate_y((rng.randf()-0.5) * PI)
		child.rotate_x((rng.randf()-0.5) * PI)
