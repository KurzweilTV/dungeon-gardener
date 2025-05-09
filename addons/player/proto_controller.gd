extends CharacterBody3D

@onready var cursor: TextureRect = $CanvasLayer/Cursor
@onready var ray_cast_3d: RayCast3D = $Head/RayCast3D
@onready var debug_ui: PanelContainer = %DebugUI
var target: Plant

## The object you want to place (set this in the editor to your Plant scene)
@export var placeable_scene : PackedScene

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"
## Name of Input Action to interact (place object)
@export var input_interact : String = "interact"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var hand: Marker3D = $Head/Hand

func _ready() -> void:
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

func _process(delta: float) -> void:
	if ray_cast_3d.is_colliding():
		var thing = ray_cast_3d.get_collider()
		if thing.name == "RayCastTarget":
			target = thing.get_parent() as Plant
			cursor.self_modulate = Color.GREEN
		else: 
			target = null
			cursor.self_modulate = Color.WHITE

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Place object on interact
	if Input.is_action_just_pressed(input_interact):
		if hand.get_child_count() == 0 and target:
			pick_up(target)
		elif hand.get_child_count() > 0:
			place_held_object()


func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting
	if can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()

func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func get_target() -> Plant:
	return target

func pick_up(plant: Plant):
	plant.reparent(hand)
	plant.position = Vector3.ZERO
	plant.rotation = Vector3.ZERO  # Make sure it's not tilted
	plant.scale = Vector3.ONE * 0.5

func place_held_object():
	if hand.get_child_count() == 0:
		return
		
	var plant = hand.get_child(0) as Plant
	if not ray_cast_3d.is_colliding():
		return
		
	var point = ray_cast_3d.get_collision_point()
	var normal = ray_cast_3d.get_collision_normal()
	
	if normal.dot(Vector3.UP) >= 0.95:  # Flat enough surface, stops placing shit on walls
		plant.reparent(get_tree().current_scene)
		plant.global_position = point
		plant.global_rotation = Vector3.ZERO  # Stand up straight!
		plant.scale = Vector3.ONE * 0.5
