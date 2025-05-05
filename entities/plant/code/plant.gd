@icon("res://entities/plant/art/plant_icon.png")
class_name Plant
extends PhysicsBody3D

@onready var plant_sprite: Sprite3D = $Sprite3D

@export_category("Growth")
@export var is_growing: bool
@export var growth_rate: float = 0.6
@export var shrink_rate: float = -0.2
@export var size_min: float = 1.0
@export var size_max: float = 6.5

@export_category("Water")
@export_range(0, 100, 5) var water_level: float
@export var is_being_watered: bool
@export var water_rate: float = 10
@export var drying_rate: float = -2
@export var water_min: float = 0.0
@export var water_max: float = 100.0

@export_category("Visuals")
@export var healthy_color: Color = Color("#00b200")
@export var unhealthy_color: Color = Color("#ff4b16")

func _process(delta: float) -> void:
	var growth := delta * (growth_rate if is_growing else shrink_rate)
	plant_sprite.scale.x = clamp(plant_sprite.scale.x + growth, size_min, size_max)
	plant_sprite.scale.y = clamp(plant_sprite.scale.y + growth, size_min, size_max)

	water_level = clamp(water_level + delta * (water_rate if is_being_watered else drying_rate), water_min, water_max)

	var plant_color: float = clamp(water_level / 100.0, 0.0, 1.0)
	plant_sprite.modulate = healthy_color.lerp(unhealthy_color, 1.0 - plant_color)

func set_watered(watered: bool) -> void:
	is_being_watered = watered

func set_growing(growing: bool) -> void:
	is_growing = growing
