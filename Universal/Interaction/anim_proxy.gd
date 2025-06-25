extends AnimationPlayer

@export var anim_name: StringName
@export var reset_on_ready: bool

func _ready() -> void:
	if (reset_on_ready):
		play("RESET")
		advance(0)

func play_anim() -> void:
	play(anim_name)
