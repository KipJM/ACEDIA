extends MeshInstance3D
class_name PlanarReflector

var reflect_camera : Camera3D
var reflect_viewport: SubViewport
@export var main_camera : Camera3D = null

@export var resolution_scale: float
@export var far : float = 4000
@export var debug_ui: TextureRect

var seen = false

func _ready():
	init_mirror();
	seen = false;

# Called when the node enters the scene tree for the first time.
func init_mirror():
	reflect_viewport = SubViewport.new();
	add_child(reflect_viewport);
	reflect_camera = Camera3D.new();
	reflect_viewport.add_child(reflect_camera);
	
	reflect_camera.cull_mask = 1;
	reflect_camera.environment = main_camera.environment
	
	reflect_camera.doppler_tracking = Camera3D.DOPPLER_TRACKING_DISABLED
	reflect_camera.keep_aspect = Camera3D.KEEP_HEIGHT
	reflect_camera.projection = Camera3D.PROJECTION_PERSPECTIVE

	reflect_camera.current = true;

	var mat:ShaderMaterial = self.get_surface_override_material(0);
	mat.set_shader_parameter("reflection_screen_texture", reflect_viewport.get_texture());
	
	if debug_ui != null:
		debug_ui.texture = reflect_viewport.get_texture()
	
	reflect_camera.make_current();
	update_viewport()

func update_viewport() -> void:
	reflect_viewport.size = get_viewport().size * resolution_scale
	#print(reflect_viewport.size)
	reflect_camera.fov = main_camera.fov
	reflect_camera.far = far # Arbitrary
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: # DEBUG
	if (!seen):
		return
	if (!main_camera):
		return

	update_viewport()
	if update_reflect_cam():
		reflect_camera.current = true;
	else:
		reflect_camera.current = false; # Not in view
	
	# DEBUG
	DebugDraw3D.scoped_config().set_thickness(0.01);
	DebugDraw3D.draw_camera_frustum(reflect_camera, Color.GREEN)
	DebugDraw3D.draw_box(reflect_camera.global_position, reflect_camera.global_basis.get_rotation_quaternion(), Vector3.ONE * 0.2, Color.GREEN, true) 


func update_reflect_cam() -> bool:
	# Mirror position
	var reflection_transform = global_transform;
	var plane_origin = reflection_transform.origin;
	var plane_normal = reflection_transform.basis.z.normalized();
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	
	var cam_pos = main_camera.global_position
	
	var proj_pos := reflection_plane.project(cam_pos)
	var mirrored_pos = cam_pos + (proj_pos - cam_pos) * 2.0
	
	# loc
	reflect_camera.global_transform.origin = mirrored_pos;
	
	# rot
	reflect_camera.global_transform.origin = mirrored_pos

	reflect_camera.basis = Basis(
		main_camera.global_basis.x.normalized().bounce(reflection_plane.normal).normalized(),
		main_camera.global_basis.y.normalized().bounce(reflection_plane.normal).normalized(),
		main_camera.global_basis.z.normalized().bounce(reflection_plane.normal).normalized()
	)
	
	# near plane	
	var camera_planes = reflect_camera.get_frustum();
	var left_plane   = camera_planes[2]
	var right_plane  = camera_planes[4]
	var top_plane    = camera_planes[3]
	var bottom_plane = camera_planes[5]
	
	var point_bl = reflection_plane.intersect_3(bottom_plane, left_plane) # yaoi
	var point_br = reflection_plane.intersect_3(bottom_plane, right_plane)
	var point_tl = reflection_plane.intersect_3(top_plane, left_plane)
	var point_tr = reflection_plane.intersect_3(top_plane, right_plane)
	
	# find min distance point (that's in frustum)
	var forward = -reflect_camera.global_basis.z
	var min_vector: Vector3
	for point in [point_bl, point_br, point_tl, point_tr]:
		var point_vector: Vector3 = point - reflect_camera.global_position;
		if forward.dot(point_vector) > 0:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SPHERE, 0.2, Color.GREEN)
			if !min_vector || point_vector.length_squared() <= min_vector.length_squared():
				min_vector = point_vector
		else:
			DebugDraw3D.draw_points([point], DebugDraw3D.POINT_TYPE_SQUARE, 0.2, Color.RED)
	
	# Frustum not in view
	if !min_vector:
		return false

	DebugDraw3D.draw_arrow_ray(reflect_camera.global_position, min_vector, 1, Color.WHITE, 0.2)

	# Turn point distance into near plane distance
	var fov_w_half = deg_to_rad(reflect_camera.get_camera_projection().get_fov())/2
	var fov_h_half = deg_to_rad(reflect_camera.fov)/2
	
	var unit_frustum_point: Vector3 = Vector3(1/tan(fov_w_half), 1/tan(fov_h_half), 1.0);
	var unit_frustum_distance = unit_frustum_point.length()
	
	reflect_camera.near = min_vector.length() / unit_frustum_distance
	
	return true

func _on_screen_entered(area: Area3D) -> void:
	if (!seen): # Enable cam
		print("Seen!")
		reflect_camera.make_current()
		update_viewport() # just to be safe
		seen = true;


func _on_screen_exited(area: Area3D) -> void:
	if(seen): 
		print("Clear")
		# Stop camera to save compute resources
		# Unfortunately VRAM is still needed :O
		# Unallocating/allocating takes too much time :|
		reflect_camera.clear_current()
		seen = false;
