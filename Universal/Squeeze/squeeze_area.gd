extends Area3D

func _physics_process(_delta: float) -> void:
	if has_overlapping_bodies():
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				body.call("InSqueeze")


func _on_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
