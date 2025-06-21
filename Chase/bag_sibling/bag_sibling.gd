extends Node3D

@export var pin: Node3D
@export_group("private")
@export var anim_player: AnimationPlayer
@export var anim_name: StringName

func play_animation():
	anim_player.play(anim_name)
