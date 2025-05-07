extends FogVolume

func _on_light_entered(area: Node3D) -> void:
	if area is Plant:
		area.set_in_sunlight(true)

func _on_light_exited(area: Node3D) -> void:
	if area is Plant:
		area.set_in_sunlight(false)
