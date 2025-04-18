@tool
extends Camera3D

func _ready() -> void:
	DebugDraw3D.scoped_config().set_thickness(0.005);
	
func _process(_delta: float) -> void:
	DebugDraw3D.scoped_config().set_thickness(0.005);
	DebugDraw3D.scoped_config().set_no_depth_test(true);
		# DEBUG
	DebugDraw3D.draw_camera_frustum(self, Color.GREEN)
	DebugDraw3D.draw_box(self.global_position, self.global_basis.get_rotation_quaternion(), Vector3.ONE * 0.2, Color.GREEN, true)
	DebugDraw3D.draw_arrow_ray(global_position, -(self.global_basis).z, 1, Color.PURPLE, 0.1) 
	DebugDraw3D.draw_arrow_ray(global_position, -(self.global_basis).rotated(Vector3.UP, deg_to_rad(get_camera_projection().get_fov()/2)).z, 1, Color.ORANGE, 0.1) 
	DebugDraw3D.draw_arrow_ray(global_position, -(self.global_basis).rotated(Vector3.RIGHT, -deg_to_rad(fov/2)).z, 1, Color.ORANGE, 0.1)
