@tool
extends Sprite3D

@export_range(0, 100, 5) var water_level: float
@export var healthy_color: Color = Color("#00b200")
@export var unhealthy_color: Color = Color("#ff4b16")

func _process(_delta):
	var plant_color : float = clamp(water_level / 100.0, 0.0, 1.0)
	modulate = healthy_color.lerp(unhealthy_color, 1.0 - plant_color)
