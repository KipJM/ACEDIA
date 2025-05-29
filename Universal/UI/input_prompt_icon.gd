extends Control

@export var pc_node: Control
@export var ps_node: Control
@export var xbox_node: Control

func _ready() -> void:
	InputHelper.device_changed.connect(_on_device_changed)
	_on_device_changed(InputHelper.device, 0)

func _on_device_changed(device: String, device_index: int) -> void:
	print(device)
	print(device_index)
	
	pc_node.visible = false
	ps_node.visible = false
	xbox_node.visible = false
	
	match device:
		InputHelper.DEVICE_KEYBOARD:
			pc_node.visible = true
		InputHelper.DEVICE_PLAYSTATION_CONTROLLER:
			ps_node.visible = true
		_:
			xbox_node.visible = true	
