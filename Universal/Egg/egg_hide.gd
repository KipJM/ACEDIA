extends Node3D

func _ready() -> void:
	if GraphicsSettings.new_game_plus:
		queue_free()
