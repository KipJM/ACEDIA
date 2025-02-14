extends Area3D

func _physics_process(_delta: float) -> void:
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				body.call("InSqueeze")
