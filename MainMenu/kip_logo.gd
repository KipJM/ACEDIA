extends TextureRect

func _ready() -> void:
	if GraphicsSettings.first_start:
		visible = true
		GraphicsSettings.first_start = false;
	else:
		visible = false
