extends Node

@export var egg_button: Button
@export var reset_button: Button

@export_group("DEBUG")
@export var debug_override: bool

func _ready() -> void:
	#if debug_override:
		#print("AHAH")
		#GraphicsSettings.new_game_plus = true
	
	if not GraphicsSettings.new_game_plus:
		print("egg intro")
		# Only finished default route
		GraphicsSettings.new_game_plus = true
		egg_button.visible = true
		reset_button.visible = false
	else:
		print("reset")
		# Egg route finished
		GraphicsSettings.new_game_plus = false
		egg_button.visible = false
		reset_button.visible = true
