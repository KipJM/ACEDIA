extends AnimationPlayer

@export
var anim_name: StringName

func _ready() -> void:
	print("PLPLP")
	play(anim_name)
