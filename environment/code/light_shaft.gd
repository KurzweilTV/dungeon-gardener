extends FogVolume

func _on_light_entered(body: Node3D) -> void:
	if body is Plant:
		body.set_growing(true)

func _on_light_exited(body: Node3D) -> void:
	if body is Plant:
		body.set_growing(false)
