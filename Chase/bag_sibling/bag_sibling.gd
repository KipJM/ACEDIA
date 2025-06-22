@tool
extends Node3D

@export var pin: Node3D
@export_group("Animatino")
@export var anim_tree: AnimationTree
@export var anim_property: StringName
@export var lerp_speed: float

var prev_position: Vector3
var prev_velocity: float

func _ready() -> void:
	prev_position = global_position

func _process(delta: float) -> void:
	var velocity = ((global_position - prev_position)	/ delta)
	
	var weight = 1 - exp(-lerp_speed * delta)
	prev_velocity = lerp(prev_velocity, global_basis.tdotz(velocity), weight)
	
	anim_tree.set(anim_property, prev_velocity)
	
	prev_position = global_position
