extends PanelContainer

@onready var health_bar: ProgressBar = %HealthBar
@onready var sun_bar: ProgressBar = %SunBar
@onready var water_bar: ProgressBar = %WaterBar
@onready var check_box: CheckBox = %CheckBox

var is_debug_ui: bool = true

func _process(_delta: float) -> void:
	if !is_debug_ui:
		visible = false
		return
	
	var player := get_tree().get_first_node_in_group("player") as Node
	if !player or !player.has_method("get_target"):
		visible = false
		return
	
	var plant = player.get_target() as Plant
	if !is_instance_valid(plant):
		visible = false
		return
	
	# Update UI and make visible
	health_bar.value = plant.plant_health
	sun_bar.value = plant.sunlight_exposure
	water_bar.value = plant.water_level
	check_box.button_pressed = plant.is_max_growth
	visible = true
