@icon("res://resources/art/leaf_icon.png")
class_name PlantStats extends Resource

@export_category("Growth")
@export var id: String
@export var growth_rate: float = 0.6
@export var shrink_rate: float = 0.2
@export var size_min: float = 1.0
@export var size_max: float = 6.5

@export_category("Water")
@export var water_min: float = 0.0
@export var water_max: float = 100.0
@export var water_low_threshold: float = 30.0
@export var water_hi_threshold: float = 60.0   # For cactus, e.g.
@export var water_rate: float = 10
@export var drying_rate: float = 2
@export var sun_dry_penalty: float = 10

@export_category("Sunlight")
@export var sunlight_min: float = 0.0
@export var sunlight_max: float = 100.0
@export var sunlight_low_threshold: float = 30
@export var sunlight_hi_threshold: float = 90
@export var sunlight_gain_rate: float = 8.0
@export var sunlight_loss_rate: float = 4.0
@export var sunlight_grow_threshold: float = 30.0
@export var light_damage_rate: float = 5.0

@export_category("Darkness")
@export var needs_darkness: bool = false  # True for mushrooms, false for others
@export var darkness_grow_threshold: float = 0.7  # How much darkness needed to grow
@export var darkness_damage_threshold: float = 0.3  # At what light level plant takes damage
@export var darkness_gain_rate: float = 1.0  # How quickly plant becomes shaded
@export var darkness_loss_rate: float = 1.0  # How quickly plant loses shade

@export_category("Visuals")
@export var healthy_color: Color = Color("#00b200")
@export var unhealthy_color: Color = Color("#ff4b16")
