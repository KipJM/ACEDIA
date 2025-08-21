extends WorldEnvironment

func _ready() -> void:
	environment.sdfgi_enabled = false;
	await get_tree().process_frame
	environment.sdfgi_enabled = true;
