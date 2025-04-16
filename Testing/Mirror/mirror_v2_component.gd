@tool
extends MeshInstance3D

@onready
var cam: Camera3D = %player_cam

@onready
var reflect_cam: Camera3D = $SubViewport/Camera3D


func _process(delta: float) -> void:
	# Mirror position
	var reflection_transform = global_transform;
	var plane_origin = reflection_transform.origin;
	var plane_normal = reflection_transform.basis.z.normalized();
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	
	var cam_pos = cam.global_position
	
	var proj_pos := reflection_plane.project(cam_pos)
	var mirrored_pos = cam_pos + (proj_pos - cam_pos) * 2.0
	
	# loc
	reflect_cam.global_transform.origin = mirrored_pos;
	
	# rot
	reflect_cam.global_transform.origin = mirrored_pos

	reflect_cam.basis = Basis(
		cam.global_basis.x.normalized().bounce(reflection_plane.normal).normalized(),
		cam.global_basis.y.normalized().bounce(reflection_plane.normal).normalized(),
		cam.global_basis.z.normalized().bounce(reflection_plane.normal).normalized()
	)
	
	# near plane
	var distance = -reflection_plane.distance_to(reflect_cam.global_position)
	
	# Horizontal
	var horiz_near: float;
	var fov_h = deg_to_rad(reflect_cam.get_camera_projection().get_fov())
	if reflect_cam.rotation.y > 0:
		# plane-left frustum (camera ->)
		var left_rot = abs(reflect_cam.rotation.y - (fov_h / 2))
		var left_near = distance * (1/cos(left_rot)) * cos(fov_h/2)
		
		horiz_near = left_near
	else:	
		# plane-right frustum (camera <-)
		var right_rot = abs(reflect_cam.rotation.y + (fov_h / 2))
		var right_near = distance * (1/cos(right_rot)) * cos(fov_h/2)
		
		horiz_near = right_near
	
	# Vertical
	var vert_near: float;
	var fov_v = deg_to_rad(reflect_cam.fov)
	
	if reflect_cam.rotation.x < 0:
		# plane-up frustum (camera v)
		var up_rot = abs(reflect_cam.rotation.x + (fov_v / 2))
		var up_near = distance * (1/cos(up_rot)) * cos(fov_v/2)
		
		vert_near = up_near;
	else:
		# plane-right frustum (camera v)
		var down_rot = abs((fov_v / 2) - reflect_cam.rotation.x)
		var down_near = distance * (1/cos(down_rot)) * cos(fov_v/2)
		
		vert_near = down_near
	
	reflect_cam.near = min(horiz_near, vert_near)
