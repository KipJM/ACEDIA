extends MeshInstance3D

@export var egg_mat: Material

func _ready() -> void:
	if GraphicsSettings.new_game_plus:
		set_surface_override_material(3, egg_mat)
