extends Area3D
class_name LocalEnvironment

@export_group("Area")
@export var area_root: Node3D

@export_group("Rendering")
@export var environment: Environment
# @export var camera_attributes: CameraAttributes
@export var directional_light: DirectionalLight3D

@export_group("Reflectors")
@export var preload_mirrors: Array[PlanarReflector]
@export var mirrors: Array[PlanarReflector]

@export_group("Portal")
@export var no_portal: bool
@export var entry_portal: Portal

var seen = false;

signal environment_entered
signal environment_seen
signal environment_exited

func body_entered(_body: Node3D) -> void:
	print("entered")
	player_entered()
	environment_entered.emit()

func body_exited(_body: Node3D) -> void:
	player_exited()
	environment_exited.emit()

func _ready() -> void:
	portal_setup()
	prehide_area()
	
	if (no_portal):
		portal_seen()
	print("ready")

func prehide_area() -> void:
	area_root.process_mode = Node.PROCESS_MODE_DISABLED
	area_root.visible = false
	
func show_area() -> void:
	area_root.process_mode = Node.PROCESS_MODE_INHERIT
	area_root.visible = true


func portal_setup() -> void:
	if (no_portal):
		return
	
	entry_portal.set_environment(environment)
	entry_portal.portal_seen.connect(portal_seen)
	
	# Set directional light to appear to portal only
	directional_light.set_layer_mask_value(18, true)
	directional_light.set_layer_mask_value(1, false)
	directional_light.set_layer_mask_value(17, false)

func portal_seen() -> void:
	if (seen): # one-shot
		return
	seen = true
	
	if (!no_portal):
		entry_portal.set_environment(environment)
	
	# Resume scene
	show_area()
	
	# Preload mirrors to prevent lag spike
	# WARNING: Don't overload VRAM!
	for mir in preload_mirrors:
		mir.init_mirror()
	
	environment_seen.emit()

func player_entered() -> void:
	%GlobalEnv.environment = environment
# 	if (camera_attributes != null):
# 		%GlobalEnv.camera_attributes = camera_attributes
	
	if (!no_portal):
		print("UHHH")
		# Set directional light to appear to player only
		directional_light.set_layer_mask_value(18, false)
		directional_light.set_layer_mask_value(17, true)
	
	# Resume scene (failsafe)
	show_area()
	
	if (!no_portal):
		# dispose entry portal
		entry_portal.destroy_mirror()

func player_exited() -> void:
	# destroy everything :)
	# dispose all mirrors
	for mirror in mirrors:
		mirror.destroy_mirror()
	
	# Destroy everything
	area_root.queue_free()
	
