extends Control

@export var settings_menu: Control
@export var credits_panel: Control

func toggle_settings() -> void:
	settings_menu.visible = !settings_menu.visible
	
func toggle_credits() -> void:
	credits_panel.visible = !credits_panel.visible

func _ready() -> void:
	settings_menu.visible = false
	credits_panel.visible = false
