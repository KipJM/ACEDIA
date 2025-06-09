extends AnimationPlayer

@export
var anim_name: StringName

func _ready() -> void:
	play(anim_name)
