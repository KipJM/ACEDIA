extends MeshInstance3D
class_name PlanarReflector

var reflect_camera: Camera3D
var reflect_viewport: SubViewport

@export var player: CharacterBody3D = null; # Preferred. Will automatically use camera of player is _main_camera is not set.
@export var camera_override: Camera3D = null # Camera override

@export_group("Display")
@export var resolution_scale: float
@export var far: float = 4000

@export_group("Debug")
@export var debug_enabled: bool = false
@export var debug_ui: TextureRect
@export var debug_frustum_script: GDScript

var _main_camera: Camera3D;

func _ready():
	init_mirror();

# Called when the node enters the scene tree for the first time.
func init_mirror():	
	update_camera()
	
	reflect_viewport = SubViewport.new();
	add_child(reflect_viewport);
	reflect_camera = Camera3D.new();
	reflect_viewport.add_child(reflect_camera);
	
	reflect_camera.cull_mask = _main_camera.cull_mask;
	
	# Mirror- hidden
	reflect_camera.set_cull_mask_value(19, false)
	
	# Player - hidden
	reflect_camera.set_cull_mask_value(20, true)
	
	
	reflect_camera.environment = _main_camera.environment
	
	reflect_camera.doppler_tracking = Camera3D.DOPPLER_TRACKING_DISABLED
	reflect_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	reflect_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	
	reflect_camera.current = true;

	var mat:ShaderMaterial = self.get_surface_override_material(0);
	mat.set_shader_parameter("reflection_screen_texture", reflect_viewport.get_texture());
	
	if debug_enabled:
		if debug_ui != null:
			debug_ui.texture = reflect_viewport.get_texture()
		
		if debug_frustum_script != null:
			reflect_camera.set_script(debug_frustum_script);
			reflect_camera.set_process(true);
	
	reflect_camera.make_current();
	update_viewport()

func update_camera() -> void:
	if (camera_override == null):
	# Auto find camera from player
		_main_camera = player.Camera;
	else:
		_main_camera = camera_override;

func update_viewport() -> void:
	update_camera()
	
	reflect_viewport.size = get_viewport().size * resolution_scale
	
	reflect_camera.fov = _main_camera.fov
	reflect_camera.far = far # Arbitrary
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void: # DEBUG
	if (!player and !camera_override):
		return
	
	update_viewport()
	
	if update_reflect_cam():
		reflect_camera.make_current()
	else:
		reflect_camera.clear_current() # Not In View
	
	# DEBUG
	


func update_reflect_cam() -> bool:
	# Mirror position
	var reflection_transform = global_transform;
	var plane_origin = reflection_transform.origin;
	var plane_normal = reflection_transform.basis.z.normalized();
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	
	var cam_pos = _main_camera.global_position
	
	var proj_pos := reflection_plane.project(cam_pos)
	var mirrored_pos = cam_pos + (proj_pos - cam_pos) * 2.0
	
	# loc
	reflect_camera.global_transform.origin = mirrored_pos;
	
	# rot
	reflect_camera.global_transform.origin = mirrored_pos

	reflect_camera.basis = Basis(
		_main_camera.global_basis.x.normalized().bounce(reflection_plane.normal).normalized(),
		_main_camera.global_basis.y.normalized().bounce(reflection_plane.normal).normalized(),
		_main_camera.global_basis.z.normalized().bounce(reflection_plane.normal).normalized()
	)
	
	#==  Dynamic near plane calculation a.k.a. Hell
		
	var camera_planes = reflect_camera.get_frustum();
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
	
	var check_point_in_view = func(point: Vector3): 
		# meet at least three
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

	var point_list = [point_bl, point_br, point_tl, point_tr, point_lb, point_lt, point_rb, point_rt, 
		mesh_bl, mesh_br, mesh_tl, mesh_tr]
	for i in len(point_list):
		var point = point_list[i]
		if !point:
			continue
			
		var point_vector: Vector3 = reflect_camera.to_local(point);
		if check_point_in_view.call(point) && -point_vector.z > 0:
			if debug_enabled:
				DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.GREEN)
			point_vectors.append(point_vector);
		else:
			if debug_enabled:
				DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.RED)
				
		if debug_enabled:
			DebugDraw3D.draw_text(point - Vector3.FORWARD * 0.1, [
				"point_bl", "point_br", "point_tl", "point_tr", "point_lb", "point_lt", "point_rb", "point_rt", 
				"mesh_bl", "mesh_br", "mesh_tl", "mesh_tr", 
				"corner_bl", "corner_br", "corner_tl", "corner_tr"][i])
	
	
	var corner_list = [corner_bl, corner_br, corner_tl, corner_tr]
	for i in len(corner_list):
		var point = corner_list[i]
		if !point:
			continue
			
		var point_vector: Vector3 = reflect_camera.to_local(point);
		if check_point_in_mesh.call(point) && -point_vector.z > 0:
			if debug_enabled:
				DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.GREEN)
			point_vectors.append(point_vector);
		else:
			if debug_enabled:
				DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.RED)
		
		if debug_enabled:
			DebugDraw3D.draw_text(point - Vector3.FORWARD * 0.1, ["corner_bl", "corner_br", "corner_tl", "corner_tr"][i])
	
	if len(point_vectors) < 1:
		return false# not in view
	
	# Find shortest near plane that doesn't remove any content
	point_vectors.sort_custom(func(a: Vector3, b: Vector3): return -a.z < -b.z)
	var target_vector = point_vectors[0]
	if debug_enabled:
		DebugDraw3D.draw_arrow_ray(reflect_camera.global_position, (reflect_camera.global_basis.inverse() * target_vector), 1, Color.WHITE, 0.2)
	
	reflect_camera.near = -target_vector.z
	return true
	#==

#func _on_screen_entered(area: Area3D) -> void:
	#if (!seen): # Enable cam
		#print("Seen!")
		#reflect_camera.make_current()
		#update_viewport() # just to be safe
		#seen = true;
#
#
#func _on_screen_exited(area: Area3D) -> void:
	#if(seen): 
		#print("Clear")
		## Stop camera to save compute resources
		## Unfortunately VRAM is still needed :O
		## Unallocating/allocating takes too much time :|
		#reflect_camera.clear_current()
		#seen = false;
