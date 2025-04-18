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
	var right_plane   = camera_planes[4] # from observer POV
	var left_plane  = camera_planes[2] # from observer POV
	var top_plane    = camera_planes[3]
	var bottom_plane = camera_planes[5]
	
	# mesh points (for high accuracy dynamic near and frustum culling)
	var mesh_size_half = Vector3(mesh.size.x/2, mesh.size.y/2, 0)
	var mesh_bl = to_global(Vector3(-mesh_size_half.x, -mesh_size_half.y, 0)) # yaoi
	var mesh_br = to_global(Vector3( mesh_size_half.x, -mesh_size_half.y, 0))
	var mesh_tl = to_global(Vector3(-mesh_size_half.x,  mesh_size_half.y, 0))
	var mesh_tr = to_global(Vector3( mesh_size_half.x,  mesh_size_half.y, 0))
	
	# plane points (arghh I don't even) 
	var point_bl = bottom_plane.intersects_segment(mesh_bl, mesh_tl)
	var point_br = bottom_plane.intersects_segment(mesh_br, mesh_tr)
	var point_tl = top_plane.intersects_segment(mesh_bl, mesh_tl)
	var point_tr = top_plane.intersects_segment(mesh_br, mesh_tr)
	
	var point_lb = left_plane.intersects_segment(mesh_bl, mesh_br)
	var point_lt = left_plane.intersects_segment(mesh_tl, mesh_tr)
	var point_rb = right_plane.intersects_segment(mesh_bl, mesh_br)
	var point_rt = right_plane.intersects_segment(mesh_tl, mesh_tr)
	
	var corner_bl = reflection_plane.intersect_3(bottom_plane, left_plane)
	var corner_br = reflection_plane.intersect_3(bottom_plane, right_plane)
	var corner_tl = reflection_plane.intersect_3(top_plane, left_plane)
	var corner_tr = reflection_plane.intersect_3(top_plane, right_plane)
	
	# find min distance point (that's in frustum)
	var forward = -reflect_cam.global_basis.z
	DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, Vector3.FORWARD, 2, Color.DARK_OLIVE_GREEN, 0.02)
	
	var check_point_in_view = func(point: Vector3): 
		# meet at least three
		var conditions_met = 0;
		if top_plane.is_point_over(point): 
			if !top_plane.has_point(point):
				return false;
		if bottom_plane.is_point_over(point):
			if !bottom_plane.has_point(point):
				return false;
		if left_plane.is_point_over(point):
			if !left_plane.has_point(point):
				return false;
		if right_plane.is_point_over(point):
			if !right_plane.has_point(point):
				return false;
		
		return true;
		
	var check_point_in_mesh = func(point: Vector3):
		var point_local = to_local(point)
		return ((-mesh_size_half.x < point_local.x && point_local.x < mesh_size_half.x) &&
		(-mesh_size_half.y < point_local.y && point_local.y < mesh_size_half.y))
	
	var point_vectors: Array[Vector3];

	var point_list = [
		point_bl, point_br, point_tl, point_tr, point_lb, point_lt, point_rb, point_rt, 
		mesh_bl, mesh_br, mesh_tl, mesh_tr]
	for i in len(point_list):
		var point = point_list[i]
		if !point:
			continue
			
		var point_vector: Vector3 = reflect_cam.to_local(point);
		if check_point_in_view.call(point):
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.GREEN)
			point_vectors.append(point_vector);
		else:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.RED)
		DebugDraw3D.draw_text(point - Vector3.FORWARD * 0.1, [
			"point_bl", "point_br", "point_tl", "point_tr", "point_lb", "point_lt", "point_rb", "point_rt", 
			"mesh_bl", "mesh_br", "mesh_tl", "mesh_tr", 
			"corner_bl", "corner_br", "corner_tl", "corner_tr"][i])
	
	var corner_list = [
		corner_bl, corner_br, corner_tl, corner_tr
	]
	for i in len(corner_list):
		var point = corner_list[i]
		if !point:
			continue
		
		var point_vector: Vector3 = reflect_cam.to_local(point);
		if check_point_in_mesh.call(point):
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.GREEN)
			point_vectors.append(point_vector);
		else:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.RED)
		DebugDraw3D.draw_text(point - Vector3.FORWARD * 0.1, ["corner_bl", "corner_br", "corner_tl", "corner_tr"][i])
			
	
	# Turn point distance into near plane distance
	# Plane near
	
	point_vectors.sort_custom(func(a: Vector3, b: Vector3): return -a.z < -b.z)
	#print()
	#for point_vector in point_vectors:
		#print(-point_vector.z)

	var target_vector = point_vectors[0]
	DebugDraw3D.draw_arrow_ray(reflect_cam.global_position, (reflect_cam.global_basis.inverse() * target_vector), 1, Color.WHITE, 0.2)
		
	reflect_cam.near = -target_vector.z
