extends MeshInstance3D
class_name PlanarReflector

var reflect_camera : Camera3D
var reflect_viewport: SubViewport
@export var main_camera : Camera3D = null
@export var far : float = 100
@export var resolution_scale_min : Vector2
@export var resolution_scale_max : float = 100
@export var debug_ui: TextureRect

var seen = false

func _ready(): # TODO REMOVE
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
	reflect_camera.projection = Camera3D.PROJECTION_FRUSTUM

	reflect_camera.current = true;

	var mat:ShaderMaterial = self.get_surface_override_material(0);
	mat.set_shader_parameter("reflection_screen_texture", reflect_viewport.get_texture());
	
	if debug_ui != null:
		debug_ui.texture = reflect_viewport.get_texture()
	
	reflect_camera.make_current();
	update_viewport()

func update_viewport() -> void:
	reflect_camera.projection = Camera3D.PROJECTION_FRUSTUM
	reflect_camera.size = mesh.size.y
	
	# Dynamic scaling
	var scale_factor = 1 - clamp(reflect_camera.near / resolution_scale_min.x, 0, 1)
	#print(scale_factor)
	
	var resolution_scale = lerp(resolution_scale_min.y, resolution_scale_max, scale_factor)
	reflect_viewport.size = mesh.size * resolution_scale
	
	print(reflect_viewport.size)
	
	reflect_camera.far = far # Arbitrary
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: # DEBUG
	if (!seen):
		return
	if (!main_camera):
		return

	update_viewport()
	update_reflect_cam()
	
	# DEBUG
	DebugDraw3D.scoped_config().set_thickness(0.01);
	DebugDraw3D.draw_camera_frustum(reflect_camera, Color.GREEN)
	DebugDraw3D.draw_box(reflect_camera.global_position, reflect_camera.global_basis.get_rotation_quaternion(), Vector3.ONE * 0.2, Color.GREEN, true) 


func update_reflect_cam():
	
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
	reflect_camera.global_basis = (Basis.FLIP_Y * Basis.FLIP_X * Basis.FLIP_Z * global_basis).rotated(Vector3.RIGHT, PI);
	
	# near plane
	var distance = -reflection_plane.distance_to(reflect_camera.global_position)
	reflect_camera.near = distance + 0.001; # Fix Clipping
		
	# offset
	var offset = to_local(reflect_camera.global_position)
	reflect_camera.frustum_offset = -Vector2(offset.x, offset.y)
	


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
