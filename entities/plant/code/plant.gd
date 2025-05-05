@icon("res://entities/plant/art/plant_icon.png")
class_name Plant extends PhysicsBody3D

@export var is_growing: bool
@export var growth_rate: float = 0.6
@export var shrink_rate: float = -0.2
@onready var plant_sprite: Sprite3D = $Sprite3D

var target_min := 0.5
var target_max := 6.5
func _process(delta: float) -> void:
	var change := delta * (growth_rate if is_growing else shrink_rate)

	plant_sprite.scale.x = clamp(plant_sprite.scale.x + change, target_min, target_max)
	plant_sprite.scale.y = clamp(plant_sprite.scale.y + change, target_min, target_max)

func set_growing(growing: bool) -> void:
	is_growing = growing
