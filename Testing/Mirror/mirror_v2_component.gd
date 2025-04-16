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
	#var distance = -reflection_plane.distance_to(reflect_cam.global_position)
	
	var camera_planes = reflect_cam.get_frustum();
	var left_plane   = camera_planes[2]
	var right_plane  = camera_planes[4]
	var top_plane    = camera_planes[3]
	var bottom_plane = camera_planes[5]
	
	var point_bl = reflection_plane.intersect_3(bottom_plane, left_plane) # yaoi
	var point_br = reflection_plane.intersect_3(bottom_plane, right_plane)
	var point_tl = reflection_plane.intersect_3(top_plane, left_plane)
	var point_tr = reflection_plane.intersect_3(top_plane, right_plane)
	
	# find min distance point (that's in frustum)
	var forward = -reflect_cam.global_basis.z
	var min_vector: Vector3
	for point in [point_bl, point_br, point_tl, point_tr]:
		var point_vector: Vector3 = point - reflect_cam.global_position;
		if forward.dot(point_vector) > 0:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SPHERE, 0.2, Color.GREEN)
			if !min_vector || point_vector.length_squared() <= min_vector.length_squared():
				min_vector = point_vector
		else:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.RED)
	
	# Frustum not in view
	if !min_vector:
		return

	DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, min_vector, 1, Color.WHITE, 0.2)

	# Turn point distance into near plane distance
	var fov_w_half = deg_to_rad(reflect_cam.get_camera_projection().get_fov())/2
	var fov_h_half = deg_to_rad(reflect_cam.fov)/2
	
	var unit_frustum_point: Vector3 = Vector3(1/tan(fov_w_half), 1/tan(fov_h_half), 1.0);
	var unit_frustum_distance = unit_frustum_point.length()
	
	reflect_cam.near = min_vector.length() / unit_frustum_distance
