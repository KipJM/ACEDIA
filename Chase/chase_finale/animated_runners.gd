@tool
extends Node3D

@export var material: Material

@export var anim_tree: AnimationTree
@export var anim_key: StringName
@export var lerp_speed: float
@export var mesh: MeshInstance3D

@export_tool_button("Update material") var update_mat_button = update_mat

var prev_position: Vector3
var prev_velocity: Vector2

func _ready() -> void:
	prev_position = global_position
	mesh.material_override = material

func _process(delta: float) -> void:
	var velocity = ((global_position - prev_position)	/ delta)
	
	var weight = 1 - exp(-lerp_speed * delta)
	
	var vel_orient: Vector3 = global_basis.inverse() * velocity # hopefully this will work?
	
	var current_vel = Vector2(vel_orient.x, -vel_orient.z)
	
	prev_velocity = lerp(prev_velocity, current_vel, weight)
	
	anim_tree.set(anim_key, prev_velocity)
	
	prev_position = global_position

func update_mat() -> void:
	mesh.material_override = material
