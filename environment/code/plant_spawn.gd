extends Node3D

@export var plant_scene = preload("res://entities/plant/plant.tscn")

var spawn_point_array: Array
var spawn_index: int = 0

@onready var spawn_1: Marker3D = $Spawn1
@onready var spawn_2: Marker3D = $Spawn2
@onready var spawn_3: Marker3D = $Spawn3
@onready var spawn_4: Marker3D = $Spawn4
@onready var spawn_5: Marker3D = $Spawn5
@onready var spawn_6: Marker3D = $Spawn6
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_point_array = [spawn_1, spawn_2, spawn_3, spawn_4, spawn_5, spawn_6]

func spawn_plant() -> void:
	var plant_instance = plant_scene.instantiate()
	var location: Marker3D = spawn_point_array[select_spawn()]
	if location.get_child_count() == 0:
		location.add_child(plant_instance)
	else: print("Slot %s is occupied" % location)
	
func select_spawn() -> int:
	var selected_point: int
	if spawn_index < 6:
		selected_point = spawn_index
		spawn_index += 1
		return selected_point
	if spawn_index == 6:
		selected_point = 0
		spawn_index = 0
		return selected_point
	else: return selected_point
		
func _on_spawn_timer_timeout() -> void:
	spawn_plant()
