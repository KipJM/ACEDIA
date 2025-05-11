extends Control

@export var pc_node: TextureRect
@export var ps_node: TextureRect
@export var xbox_node: TextureRect

func _ready() -> void:
	InputHelper.device_changed.connect(_on_device_changed)
	_on_device_changed(InputHelper.device, 0)

func _on_device_changed(device: String, device_index: int) -> void:
	print(device)
	print(device_index)
	pc_node.visible = (device == InputHelper.DEVICE_KEYBOARD)
	ps_node.visible = (device == InputHelper.DEVICE_PLAYSTATION_CONTROLLER)
	xbox_node.visible = ! (pc_node.visible || ps_node.visible) # catch all
