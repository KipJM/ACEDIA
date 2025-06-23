extends AnimationPlayer

@export var anim_name: StringName

func play_anim() -> void:
	play(anim_name)
