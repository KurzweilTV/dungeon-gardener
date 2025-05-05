extends FogVolume

func _on_light_entered(body: Node3D) -> void:
	if body is Plant:
		print_rich("[color=green]Plant is growing!")
		body.set_growing(true)



func _on_light_exited(body: Node3D) -> void:
	if body is Plant:
		print_rich("[color=red]Plant is not growing")
		body.set_growing(false)
