extends Area3D

func _on_plant_entered(body: Node3D) -> void:
	if body is Plant:
		body.set_in_darkness(true)

func _on_plant_exited(body: Node3D) -> void:
	if body is Plant:
		body.set_in_darkness(false)
