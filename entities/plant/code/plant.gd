@icon("res://entities/plant/art/plant_icon.png")
class_name Plant
extends Area3D

signal plant_grown

enum PlantType { TOMATO, CACTUS, MUSHROOM }

# Choose the stats resource for this plant
@export_category("Setup")
@export var plant_type: PlantType = PlantType.TOMATO
@export var stats: PlantStats  # Should be PlantStats

@onready var plant_sprite: Sprite3D = $Sprite3D
@onready var pot: MeshInstance3D = %Pot
@onready var wet_particles: GPUParticles3D = %WaterParticles
@onready var dry_particles: GPUParticles3D = %DryParticles
@onready var frying_sound: AudioStreamPlayer3D = $FryingSound

# State variables
var growth_amount: float = 0
var is_max_growth: bool = false
var water_level: float = 0
var is_being_watered: bool = false
var sunlight_exposure: float = 0
var is_in_sunlight: bool = false
var is_in_darkness: bool = false  # Used by mushroom

func _ready():
	# Optionally, you can initialize levels here
	water_level = stats.water_max
	sunlight_exposure = stats.sunlight_min

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
	var low_water = water_level <= stats.water_low_threshold
	dry_particles.emitting = low_water
	var can_grow = sunlight_exposure > stats.sunlight_grow_threshold and not low_water and not is_max_growth
	if can_grow:
		set_growth_amount(delta)
	if sunlight_exposure > stats.sunlight_max:
		set_burning(true)
	else:
		set_burning(false)

func _process_cactus(delta: float) -> void:
	var low_water = water_level < stats.water_low_threshold
	dry_particles.emitting = low_water
	if low_water:
		return
	elif water_level > stats.water_hi_threshold:
		set_growth_amount(-delta)
	elif sunlight_exposure > stats.sunlight_grow_threshold and not is_max_growth:
		set_growth_amount(delta * 0.8)

func _process_mushroom(delta: float) -> void:
	var low_water = water_level <= stats.water_low_threshold
	dry_particles.emitting = low_water
	var can_grow = is_in_darkness and not low_water and not is_max_growth
	if can_grow:
		set_growth_amount(delta * 0.7)

func set_growth_amount(delta: float) -> void:
	var growth = delta * (stats.growth_rate if delta > 0 else stats.shrink_rate)
	plant_sprite.scale.x = clamp(plant_sprite.scale.x + growth, stats.size_min, stats.size_max)
	plant_sprite.scale.y = clamp(plant_sprite.scale.y + growth, stats.size_min, stats.size_max)
	if plant_sprite.scale.x >= stats.size_max and not is_max_growth:
		set_max_growth()

func update_water_level(delta: float) -> void:
	var dry_rate = stats.drying_rate
	if is_in_sunlight:
		dry_rate += stats.sun_dry_penalty

	if is_being_watered:
		water_level = clamp(water_level + delta * stats.water_rate, stats.water_min, stats.water_max)
	else:
		water_level = clamp(water_level - delta * dry_rate, stats.water_min, stats.water_max)

func update_sunlight_exposure(delta: float) -> void:
	if is_in_sunlight:
		sunlight_exposure = clamp(sunlight_exposure + delta * stats.sunlight_gain_rate, stats.sunlight_min, stats.sunlight_max)
	else:
		sunlight_exposure = clamp(sunlight_exposure - delta * stats.sunlight_loss_rate, stats.sunlight_min, stats.sunlight_max)

func update_soil_visuals() -> void:
	var healthy_color = stats.healthy_color if "healthy_color" in stats else Color("#00b200")
	var unhealthy_color = stats.unhealthy_color if "unhealthy_color" in stats else Color("#ff4b16")

	var plant_color: float = clamp(water_level / stats.water_max, 0.0, 1.0)
	plant_sprite.modulate = healthy_color.lerp(unhealthy_color, 1.0 - plant_color)

	var surface_material = pot.get_surface_override_material(1)
	if surface_material:
		surface_material.roughness = lerp(1.0, 0.0, plant_color)

func set_burning(burning: bool) -> void:
	if burning and not frying_sound.playing:
		frying_sound.play()
	elif not burning and frying_sound.playing:
		frying_sound.stop()

func set_watered(watered: bool) -> void:
	wet_particles.emitting = watered
	is_being_watered = watered

func set_in_sunlight(in_sun: bool) -> void:
	is_in_sunlight = in_sun

func set_in_darkness(in_dark: bool) -> void:
	is_in_darkness = in_dark

func set_max_growth() -> void:
	is_max_growth = true
	print("Max Growth")
	emit_signal("plant_grown")
