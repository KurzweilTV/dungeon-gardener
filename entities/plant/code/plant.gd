@icon("res://entities/plant/art/plant_icon.png")
class_name Plant
extends Area3D

signal plant_grown

enum PlantType { TOMATO, CACTUS, MUSHROOM }

@onready var plant_sprite: Sprite3D = $Sprite3D
@onready var pot: MeshInstance3D = %Pot
@onready var plant_particles: GPUParticles3D = $PlantParticles

@export_category("Lifecycle")
@export var plant_type: PlantType = PlantType.TOMATO

@export_category("Growth")
@export_range(0, 100, 5) var growth_amount: float
@export var is_max_growth: bool
@export var growth_rate: float = 0.6
@export var shrink_rate: float = 0.2
@export var size_min: float = 1.0
@export var size_max: float = 6.5

@export_category("Water")
@export_range(0, 100, 5) var water_level: float
@export var is_being_watered: bool
@export var water_rate: float = 10
@export var drying_rate: float = 2
@export var water_min: float = 0.0
@export var water_max: float = 100.0
@export var sun_dry_penalty: float = 10

@export_category("Sunlight")
@export_range(0, 100, 5) var sunlight_exposure: float
@export var is_in_sunlight: bool
@export var sunlight_gain_rate: float = 8.0
@export var sunlight_loss_rate: float = 4.0
@export var sunlight_min: float = 0.0
@export var sunlight_max: float = 100.0

@export_category("Visuals")
@export var healthy_color: Color = Color("#00b200")
@export var unhealthy_color: Color = Color("#ff4b16")

@export var is_in_darkness: bool = false # Used by mushroom

func _process(delta: float) -> void:
	update_water_level(delta)
	update_sunlight_exposure(delta)

	match plant_type:
		PlantType.TOMATO:
			_process_tomato(delta)
		PlantType.CACTUS:
			_process_cactus(delta)
		PlantType.MUSHROOM:
			_process_mushroom(delta)
	update_soil_visuals()

func _process_tomato(delta: float) -> void:
	var can_grow = sunlight_exposure > 30 and water_level > 30 and not is_max_growth
	if can_grow:
		set_growth_amount(delta)

func _process_cactus(delta: float) -> void:
	if water_level < 20:
		pass
	elif water_level > 60:
		set_growth_amount(-delta)
	elif sunlight_exposure > 30 and not is_max_growth:
		set_growth_amount(delta * 0.8) # grows, but slowly

func _process_mushroom(delta: float) -> void:
	var can_grow = is_in_darkness and water_level > 40 and not is_max_growth
	if can_grow:
		set_growth_amount(delta * 0.7)

func set_growth_amount(delta) -> void:
	var growth = delta * (growth_rate if delta > 0 else shrink_rate)
	plant_sprite.scale.x = clamp(plant_sprite.scale.x + growth, size_min, size_max)
	plant_sprite.scale.y = clamp(plant_sprite.scale.y + growth, size_min, size_max)
	if plant_sprite.scale.x >= size_max and !is_max_growth:
		set_max_growth()

# Water ticker (unchanged)
func update_water_level(delta: float) -> void:
	if is_being_watered:
		water_level = clamp(water_level + delta * water_rate, water_min, water_max)
	else:
		water_level = clamp(water_level - delta * drying_rate, water_min, water_max)

# Sunlight ticker
func update_sunlight_exposure(delta: float) -> void:
	if is_in_sunlight:
		sunlight_exposure = clamp(sunlight_exposure + delta * sunlight_gain_rate, sunlight_min, sunlight_max)
	else:
		sunlight_exposure = clamp(sunlight_exposure - delta * sunlight_loss_rate, sunlight_min, sunlight_max)

func update_soil_visuals() -> void:
	var plant_color: float = clamp(water_level / 100.0, 0.0, 1.0)
	plant_sprite.modulate = healthy_color.lerp(unhealthy_color, 1.0 - plant_color)

	var surface_material = pot.get_surface_override_material(1)
	if surface_material:
		surface_material.roughness = lerp(1.0, 0.0, plant_color)

func set_watered(watered: bool) -> void:
	is_being_watered = watered
	plant_particles.emitting = watered

func set_in_sunlight(in_sun: bool) -> void:
	is_in_sunlight = in_sun
	if in_sun:
		drying_rate += sun_dry_penalty
	else: drying_rate -= sun_dry_penalty

func set_in_darkness(in_dark: bool) -> void:
	is_in_darkness = in_dark

func set_max_growth() -> void:
	is_max_growth = true
	print("Max Growth")
