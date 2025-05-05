@icon("res://entities/plant/art/plant_icon.png")
class_name Plant extends PhysicsBody3D

@export var is_growing: bool
@export var growth_rate: float = 0.2
@onready var plant_sprite: Sprite3D = $Sprite3D

func _process(delta: float) -> void:
	if is_growing:
		plant_sprite.scale.x = min(plant_sprite.scale.x + delta * growth_rate, 1.5)
		plant_sprite.scale.y = min(plant_sprite.scale.y + delta * growth_rate, 1.5)

func set_growing(growing: bool) -> void:
	is_growing = growing
