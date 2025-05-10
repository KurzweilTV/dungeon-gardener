@icon("res://entities/plant/art/plant_icon.png")
class_name Plant
extends Area3D

signal plant_grown

@export_category("Setup")
@export var stats: PlantStats
@export var plant_health: float = 50
@export var plant_id: String = "tomato" # "cactus", "tomato"

@onready var pot: MeshInstance3D = %Pot
@onready var cactus: MeshInstance3D = %Cactus
@onready var tomato: MeshInstance3D = %Tomato
@onready var mushroom: MeshInstance3D = %Mushroom

@onready var wet_particles: GPUParticles3D = %WaterParticles
@onready var dry_particles: GPUParticles3D = %DryParticles
@onready var burn_particles: GPUParticles3D = %BurnParticles
@onready var watered_sound: AudioStreamPlayer3D = $WateredSound

# State variables
var growth_amount: float = 0
var is_max_growth: bool = false
var water_level: float = 0
var is_being_watered: bool = false
var sunlight_exposure: float = 0
var is_burning: bool
var is_in_sunlight: bool = false
var is_in_darkness: bool = false # reserved for mushroom
var darkness_level: float = 0.0

var plant_models: Dictionary
var active_model: Node3D

func _ready() -> void:
	plant_models = {
		"tomato": tomato,
		"cactus": cactus,
		"mushroom": mushroom,
	}

	for id in plant_models.keys():
		var model = plant_models[id]
		if model:
			model.visible = (id == plant_id)

	active_model = plant_models.get(plant_id, null)
	if active_model:
		active_model.scale = Vector3.ONE * stats.size_min
	is_in_darkness = false

func _process(delta: float) -> void:
	update_sounds()
	update_water_level(delta)
	update_sunlight_exposure(delta)
	process_plant_state(delta)
	update_soil_visuals()

func process_plant_state(delta: float) -> void:
	if plant_health <= 0:
		return
	var low_water = water_level <= stats.water_low_threshold
	var can_grow: bool
	
	if stats.needs_darkness:
		# Darkness-loving plants (mushrooms) - need darkness to grow
		can_grow = (is_in_darkness and darkness_level > stats.darkness_grow_threshold and 
				   not low_water and not is_max_growth)
		
		# Take additional damage if in too much light (on top of burning)
		if sunlight_exposure > stats.darkness_damage_threshold:
			plant_health -= delta * stats.light_damage_rate
	else:
		# Sun-loving plants (tomato, cactus) - need sunlight to grow
		can_grow = (sunlight_exposure > stats.sunlight_grow_threshold and 
				   not low_water and not is_max_growth)
	
	# UNIVERSAL BURNING MECHANIC - affects all plants
	var should_burn = sunlight_exposure > stats.sunlight_hi_threshold
	if is_burning != should_burn:
		set_burning(should_burn)
	
	if can_grow:
		set_growth_amount(delta)

func set_growth_amount(delta: float) -> void:
	if not active_model:
		return

	var growth = delta * (stats.growth_rate if delta > 0 else stats.shrink_rate)
	var new_scale = clamp(active_model.scale.x + growth, stats.size_min, stats.size_max)
	active_model.scale = Vector3.ONE * new_scale

	if new_scale >= stats.size_max and not is_max_growth:
		set_max_growth()

func update_sounds() -> void:
	if is_burning:
		pass
	else:
		pass
	if is_being_watered:
		if !watered_sound.playing:
			watered_sound.play()
	else:
		watered_sound.stop()

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
		sunlight_exposure = clamp(sunlight_exposure + delta * stats.sunlight_gain_rate, 
								stats.sunlight_min, stats.sunlight_max)
		if stats.needs_darkness:
			darkness_level = clamp(darkness_level - delta * stats.darkness_loss_rate, 0, 1)
	else:
		sunlight_exposure = clamp(sunlight_exposure - delta * stats.sunlight_loss_rate, 
								stats.sunlight_min, stats.sunlight_max)
		if stats.needs_darkness:
			darkness_level = clamp(darkness_level + delta * stats.darkness_gain_rate, 0, 1)

func update_soil_visuals() -> void:
	var surface_material = pot.get_surface_override_material(1)
	if surface_material:
		surface_material.roughness = lerp(1.0, 0.0, clamp(water_level / stats.water_max, 0.0, 1.0))

func set_burning(burning: bool) -> void:
	is_burning = burning
	burn_particles.emitting = burning

func set_watered(watered: bool) -> void:
	wet_particles.emitting = watered
	is_being_watered = watered

func set_in_sunlight(in_sun: bool) -> void:
	is_in_sunlight = in_sun

func set_in_darkness(in_dark: bool) -> void:
	is_in_darkness = in_dark

func set_max_growth() -> void:
	is_max_growth = true
	emit_signal("plant_grown")
