@tool
extends Node3D
class_name PortalTarget

@export var portal: Portal

@export_group("DEBUG")
@export var debug_enabled: bool

func _process(delta: float) -> void:
	if (debug_enabled):
# 		print("AH")
		DebugDraw3D.draw_box(global_position, global_basis.get_rotation_quaternion(), Vector3(portal.mesh.size.x, portal.mesh.size.y, 0.1), Color.AQUA, true)
