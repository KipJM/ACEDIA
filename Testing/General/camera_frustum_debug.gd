@tool
extends Camera3D

func _ready() -> void:
	DebugDraw3D.scoped_config().set_thickness(0.01);
	
func _process(delta: float) -> void:
		# DEBUG
	DebugDraw3D.draw_camera_frustum(self, Color.GREEN)
	DebugDraw3D.draw_box(self.global_position, self.global_basis.get_rotation_quaternion(), Vector3.ONE * 0.2, Color.GREEN, true) 
