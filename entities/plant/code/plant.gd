@icon("res://entities/plant/art/plant_icon.png")
class_name Plant
extends Area3D

signal plant_grown

@export_category("Setup")
@export var stats: PlantStats
@export var plant_health: float = 50
@export var plant_id: String = "tomato" # "cactus", "tomato"
@export var is_dead: bool = false:
	set(value):
		is_dead = value
		plant_die()

@onready var pot: MeshInstance3D = %Pot
@onready var cactus: MeshInstance3D = %Cactus
@onready var tomato: MeshInstance3D = %Tomato
@onready var mushroom: MeshInstance3D = %Mushroom

@onready var full_grown_particles: GPUParticles3D = %FullGrownParticles
@onready var good_particles: GPUParticles3D = %GoodParticles
@onready var death_particles: GPUParticles3D = %DeathParticles
@onready var wet_particles: GPUParticles3D = %WaterParticles
@onready var dry_particles: GPUParticles3D = %DryParticles
@onready var shade_particles: GPUParticles3D = %NeedSunParticles
@onready var burn_particles: GPUParticles3D = %BurnParticles
@onready var watered_sound: AudioStreamPlayer3D = $WateredSound
@onready var death_sound: AudioStreamPlayer3D = %DeathSound

# State variables
var growth_amount: float = 0
var is_max_growth: bool = false
var water_level: float = 0
var is_being_watered: bool = false
var sunlight_exposure: float = 0
var is_burning: bool
var is_in_sunlight: bool = false
var is_in_darkness: bool = false # for the shroom
var darkness_level: float = 0.0

var plant_models: Dictionary
var active_model: Node3D

var should_emit_good_particles: bool = false
var should_emit_wet_particles: bool = false
var should_emit_dry_particles: bool = false
var should_emit_shade_particles: bool = false
var should_emit_burn_particles: bool = false
var should_emit_death_particles: bool = false
var should_emit_full_grown_particles: bool = false


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
	_process_particles()

func process_plant_state(delta: float) -> void:
	if is_dead: return
	var low_water = water_level <= stats.water_low_threshold
	var can_grow: bool
	
	if stats.needs_darkness:
		can_grow = (is_in_darkness and darkness_level > stats.darkness_grow_threshold and 
				   not low_water and not is_max_growth)
		
		if sunlight_exposure > stats.darkness_damage_threshold:
			plant_health -= delta * stats.light_damage_rate
			if plant_health <= 0: is_dead = true
	else:
		can_grow = (sunlight_exposure > stats.sunlight_grow_threshold and 
				   not low_water and not is_max_growth)
	
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

func _process_particles() -> void:
	var all_particles = [wet_particles, burn_particles, dry_particles, shade_particles]
	if is_max_growth or is_dead:
		for particle: GPUParticles3D in all_particles:
			particle.emitting = false
		return

	should_emit_wet_particles = is_being_watered and water_level < stats.water_hi_threshold

	should_emit_burn_particles = is_burning
	
	should_emit_dry_particles = (not is_being_watered and water_level <= stats.water_low_threshold)
	
	should_emit_shade_particles = (sunlight_exposure < stats.sunlight_low_threshold)
	
	should_emit_good_particles = (not should_emit_burn_particles and not should_emit_dry_particles and not should_emit_shade_particles and not is_max_growth)

	wet_particles.emitting = should_emit_wet_particles
	dry_particles.emitting = should_emit_dry_particles
	burn_particles.emitting = should_emit_burn_particles
	shade_particles.emitting = should_emit_shade_particles
	good_particles.emitting = should_emit_good_particles

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
		sunlight_exposure = clamp(sunlight_exposure + delta * stats.sunlight_gain_rate, stats.sunlight_min, stats.sunlight_max)
		if stats.needs_darkness:
			darkness_level = clamp(darkness_level - delta * stats.darkness_loss_rate, 0, 1)
	else:
		sunlight_exposure = clamp(sunlight_exposure - delta * stats.sunlight_loss_rate, stats.sunlight_min, stats.sunlight_max)
		if stats.needs_darkness:
			darkness_level = clamp(darkness_level + delta * stats.darkness_gain_rate, 0, 1)

func update_soil_visuals() -> void:
	var surface_material = pot.get_surface_override_material(1)
	if surface_material:
		surface_material.roughness = lerp(1.0, 0.0, clamp(water_level / stats.water_max, 0.0, 1.0))

func set_burning(burning: bool) -> void:
	is_burning = burning

func set_watered(watered: bool) -> void:
	is_being_watered = watered

func set_in_sunlight(in_sun: bool) -> void:
	is_in_sunlight = in_sun

func set_in_darkness(in_dark: bool) -> void:
	is_in_darkness = in_dark

func set_max_growth() -> void:
	is_max_growth = true
	full_grown_particles.emitting = true
	emit_signal("plant_grown")

func plant_die() -> void:
	death_particles.emitting = true
	death_sound.play()

	var things = [pot, tomato, cactus, mushroom]
	for thing: MeshInstance3D in things:
		thing.hide()
		
	await get_tree().create_timer(5).timeout
	queue_free()
