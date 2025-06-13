extends Area3D
class_name LocalEnvironment

@export_group("Area")
@export var area_root: Node3D

@export_group("Rendering")
@export var environment: Environment
@export var camera_attributes: CameraAttributes
@export var directional_light: DirectionalLight3D

@export_group("Reflectors")
@export var mirrors: Array[PlanarReflector]

@export_group("Portal")
@export var entry_portal: Portal #TODO

var seen = false;

func body_entered(_body: Node3D) -> void:
	player_entered()

func body_exited(_body: Node3D) -> void:
	player_exited()

func _ready() -> void:
	portal_setup()
	prehide_area()


func prehide_area() -> void:
	area_root.process_mode = Node.PROCESS_MODE_DISABLED
	area_root.visible = false
	
func show_area() -> void:
	area_root.process_mode = Node.PROCESS_MODE_INHERIT
	area_root.visible = true


func portal_setup() -> void:
	# TODO
	#if (environment != null):
		#entry_portal.environment = environment
	
	# Set directional light to appear to portal only
	directional_light.set_layer_mask_value(18, false)
	directional_light.set_layer_mask_value(1, true)

func portal_seen() -> void:
	if (seen): # one-shot
		return
	seen = true
	
	# Resume scene
	show_area()

func player_entered() -> void:
	if (environment != null):
		%GlobalEnv.environment = environment
	if (camera_attributes != null):
		%GlobalEnv.camera_attributes = camera_attributes
	
	# Set directional light to appear to player only
	directional_light.set_layer_mask_value(18, false)
	directional_light.set_layer_mask_value(1, true)
	
	# Resume scene (failsafe)
	show_area()
	
	# dispose entry portal
	#entry_portal.destroy_mirror() # TODO

func player_exited() -> void:
	# destroy everything :)
	# dispose all mirrors
	for mirror in mirrors:
		mirror.destroy_mirror()
	
	# Destroy everything
	area_root.queue_free()
	
