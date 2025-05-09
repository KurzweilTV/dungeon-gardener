extends CanvasLayer

@onready var plant: Plant = $".."
@onready var health_bar: ProgressBar = %HealthBar
@onready var sun_bar: ProgressBar = %SunBar
@onready var water_bar: ProgressBar = %WaterBar
@onready var check_box: CheckBox = %CheckBox

var is_debug_ui: bool = true

func _ready() -> void:
	health_bar.value = plant.plant_health
	sun_bar.value = plant.sunlight_exposure
	water_bar.value = plant.water_level

func _process(_delta: float) -> void:
	if !is_debug_ui:
		return
		
	health_bar.value = plant.plant_health
	sun_bar.value = plant.sunlight_exposure
	water_bar.value = plant.water_level
	
	if plant.is_max_growth:
		check_box.button_pressed = true
