extends MeshInstance3D

@export var mat_ind: int
@export var new_mat: Material

func _ready() -> void:
	if GraphicsSettings.new_game_plus:
		set_surface_override_material(mat_ind, new_mat)
