extends Node

@export
var locked: bool = false

@export
var tree: AnimationTree

var open = false

func toggle_door() -> void:
	if !locked:
		open = !open
		update_door()
	else:
		jiggle_door()


func update_door() -> void:
	if open:
		tree["parameters/playback"].travel("Open")
	else:
		tree["parameters/playback"].travel("Close")

func jiggle_door() -> void:
	tree["parameters/playback"].travel("handleJiggle")
