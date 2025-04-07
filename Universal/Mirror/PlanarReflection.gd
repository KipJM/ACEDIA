extends MeshInstance3D
class_name PlanarReflector

var reflect_camera : Camera3D
var reflect_viewport: SubViewport
@export var main_cam : Camera3D = null
@export var resolution_scale : float = 1
@export var debug_ui: TextureRect


var seen = false

func _ready(): # TODO REMOVE
	init_mirror();
	seen = false;

# Called when the node enters the scene tree for the first time.
func init_mirror():
	reflect_viewport = SubViewport.new();
	add_child(reflect_viewport);
	update_viewport()
	reflect_camera = Camera3D.new();
	reflect_viewport.add_child(reflect_camera);
	reflect_camera.cull_mask = 1;
	reflect_camera.fov = main_cam.fov
	reflect_camera.environment = main_cam.environment
	reflect_camera.doppler_tracking = main_cam.doppler_tracking
	reflect_camera.projection = Camera3D.PROJECTION_FRUSTUM
	
	# Cam attributes
	var main_cam_attr = main_cam.attributes
	if main_cam_attr is CameraAttributesPhysical:
		print("physical!")
		var attrPhys = CameraAttributesPhysical.new()
		attrPhys.frustum_focus_distance = main_cam_attr.frustum_focus_distance
		attrPhys.frustum_focal_length = main_cam_attr.frustum_focal_length
		attrPhys.frustum_near = main_cam_attr.frustum_near
		attrPhys.frustum_far = main_cam_attr.frustum_far
		
		attrPhys.exposure_multiplier = main_cam_attr.exposure_multiplier
		attrPhys.auto_exposure_enabled = false;
		
		reflect_camera.attributes = attrPhys
	elif main_cam_attr is CameraAttributesPractical:
		print("Practical!")
		var attrPrac = CameraAttributesPractical.new()
		attrPrac.dof_blur_far_enabled = false;
		attrPrac.dof_blur_near_enabled = false;
		attrPrac.exposure_multiplier = main_cam_attr.exposure_multiplier
		attrPrac.auto_exposure_enabled = false;
		
		reflect_camera.attributes = attrPrac
	else:
		print(main_cam_attr)
	reflect_camera.current = true;

	var mat:ShaderMaterial = self.get_surface_override_material(0);
	mat.set_shader_parameter("reflection_screen_texture", reflect_viewport.get_texture());
	
	if debug_ui != null:
		debug_ui.texture = reflect_viewport.get_texture()
	
	reflect_camera.make_current();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (!seen):
		return
	
	update_viewport()
	if (!main_cam):
		return

	var reflection_transform = global_transform * Transform3D().rotated(Vector3.RIGHT, PI/2);
	var plane_origin = reflection_transform.origin;
	var plane_normal = reflection_transform.basis.z.normalized();
	var reflection_plane = Plane(plane_normal, plane_origin.dot(plane_normal))
	
	var cam_pos = main_cam.global_transform.origin
	
	var proj_pos := reflection_plane.project(cam_pos)
	var mirrored_pos = cam_pos + (proj_pos - cam_pos) * 2.0
	
	reflect_camera.global_transform.origin = mirrored_pos

	#reflect_camera.basis = Basis(
		#main_cam.global_basis.x.normalized().bounce(reflection_plane.normal).normalized(),
		#main_cam.global_basis.y.normalized().bounce(reflection_plane.normal).normalized(),
		#main_cam.global_basis.z.normalized().bounce(reflection_plane.normal).normalized()
	#)

	# https://github.com/Norodix/GodotMirror/blob/master/addons/Mirror/Mirror/Mirror.gd
	
	# Transform the mirror camera to the opposite side of the mirror plane
	var MirrorNormal = global_transform.basis.z	
	var MirrorTransform =  Mirror_transform(MirrorNormal, global_transform.origin)
	reflect_camera.global_transform = MirrorTransform * main_cam.global_transform
	
	# Look perpendicular into the mirror plane for frostum camera
	reflect_camera.global_transform = reflect_camera.global_transform.looking_at(
			reflect_camera.global_transform.origin/2 + main_cam.global_transform.origin/2, \
			global_transform.basis.y
		)
	var cam2mirror_offset = global_transform.origin - reflect_camera.global_transform.origin
	var near = abs((cam2mirror_offset).dot(MirrorNormal)) # near plane distance
	near += 0.05 # avoid rendering own surface

	# transform offset to camera's local coordinate system (frostum offset uses local space)
	var cam2mirror_camlocal = reflect_camera.global_transform.basis.inverse() * cam2mirror_offset
	var frostum_offset =  Vector2(cam2mirror_camlocal.x, cam2mirror_camlocal.y)
	reflect_camera.set_frustum(mesh.size.x * scale.x, frostum_offset, near, 10000)
	
	DebugDraw3D.scoped_config().set_thickness(0.001);
	# DEBUG
	DebugDraw3D.draw_box(reflect_camera.global_position, reflect_camera.global_basis.get_rotation_quaternion(), Vector3.ONE * 0.2, Color.GREEN, true) 


# n is the normal of the mirror plane
# d is the offset from the plane of the mirrored object
# Gets the transformation that mirrors through the plane with normal n and offset d
func Mirror_transform(n : Vector3, d : Vector3) -> Transform3D:
	var basisX : Vector3 = Vector3(1.0, 0, 0) - 2 * Vector3(n.x * n.x, n.x * n.y, n.x * n.z)
	var basisY : Vector3 = Vector3(0, 1.0, 0) - 2 * Vector3(n.y * n.x, n.y * n.y, n.y * n.z)
	var basisZ : Vector3 = Vector3(0, 0, 1.0) - 2 * Vector3(n.z * n.x, n.z * n.y, n.z * n.z)
	
	var offset = Vector3.ZERO
	offset = 2 * n.dot(d)*n
	
	return Transform3D(Basis(basisX, basisY, basisZ), offset)	
	pass



func update_viewport() -> void:
	reflect_viewport.size = get_viewport().size * resolution_scale


func _on_screen_entered(area: Area3D) -> void:
	if (!seen): # Enable cam
		print("Seen!")
		reflect_camera.make_current()
		seen = true;


func _on_screen_exited(area: Area3D) -> void:
	if(seen): 
		print("Clear")
		# Stop camera to save compute resources
		# Unfortunately VRAM is still needed :O
		# Unallocating/allocating takes too much time :|
		reflect_camera.clear_current()
		seen = false;
