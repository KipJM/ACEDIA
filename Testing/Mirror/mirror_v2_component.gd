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
	
	# mesh points (for high accuracy dynamic near and frustum culling)
	var mesh_size_half = Vector3(mesh.size.x/2, mesh.size.y/2, 0)
	var mesh_bl = to_global(Vector3(-mesh_size_half.x, -mesh_size_half.y, 0))
	var mesh_br = to_global(Vector3( mesh_size_half.x, -mesh_size_half.y, 0))
	var mesh_tl = to_global(Vector3(-mesh_size_half.x,  mesh_size_half.y, 0))
	var mesh_tr = to_global(Vector3( mesh_size_half.x,  mesh_size_half.y, 0))
	
	# find min distance point (that's in frustum)
	var forward = -reflect_cam.global_basis.z
	DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, Vector3.FORWARD, 2, Color.DARK_OLIVE_GREEN, 0.02)
	
	var min_vector: Vector3 = Vector3.ONE * 100000
	for point in [point_bl, point_br, point_tl, point_tr]:
		var point_vector: Vector3 = reflect_cam.to_local(point);
		DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, point_vector, 2, Color.PURPLE, 0.02)
		if -point_vector.z > 0:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SPHERE, 0.2, Color.GREEN)
			
			if point_vector.length_squared() <= min_vector.length_squared():
				min_vector = point_vector
		else:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SPHERE, 0.2, Color.RED)
	
	if min_vector == Vector3.ONE * 100000:
		#print("Hidden (Plane)")
		return
	
	var min_mesh_vector: Vector3 = Vector3.ONE * 100000
	for point in [mesh_bl, mesh_br, mesh_tl, mesh_tr]:
		var point_vector: Vector3 = reflect_cam.to_local(point);
		DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, point_vector, 2, Color.PINK, 0.02)
		if -point_vector.z > 0:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.GREEN)
			
			if point_vector.length_squared() <= min_mesh_vector.length_squared():
				min_mesh_vector = point_vector
		else:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.RED)
	
	
	# Frustum not in view
	if min_mesh_vector == Vector3.ONE * 100000:
		#print("Hidden (Mesh)")
		return

	# Turn point distance into near plane distance
	var fov_w_half = deg_to_rad(reflect_cam.get_camera_projection().get_fov())/2
	var fov_h_half = deg_to_rad(reflect_cam.fov)/2
	
	# Plane near
	if false:
		DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, reflect_cam.basis.inverse() * min_vector, 1, Color.WHITE, 0.2)
		
		#var unit_frustum_point: Vector3 = Vector3(1/tan(fov_w_half), 1/tan(fov_h_half), 1.0);
		#var unit_frustum_distance = unit_frustum_point.length()
		#print(min_vector.z)
		reflect_cam.near = -min_vector.z
	else:
		DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, reflect_cam.basis.inverse() * min_mesh_vector, 1, Color.BLACK, 0.2)
		# Mesh near
		reflect_cam.near = -min_mesh_vector.z
