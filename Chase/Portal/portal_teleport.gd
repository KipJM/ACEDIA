extends Area3D

@export var portal: Portal

func teleport() -> void:
	var body: CharacterBody3D = %Player.Body
	var portal_target = portal.portal_target
	body.global_position = portal_target.to_global(portal.to_local(body.global_position))
	body.global_basis = portal_target.basis * global_basis.inverse() * body.global_basis
	body.move_and_slide()

func _on_body_entered(body: Node3D) -> void:
	teleport()
