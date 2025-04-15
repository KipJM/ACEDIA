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
	reflect_cam.global_basis = Basis.FLIP_Y * Basis.FLIP_X * Basis.FLIP_Z * global_basis;
	
	# near plane
	var distance = -reflection_plane.distance_to(reflect_cam.global_position)
	reflect_cam.near = distance;
	
	var offset = to_local(reflect_cam.global_position)
	# X
	reflect_cam.frustum_offset = offset
