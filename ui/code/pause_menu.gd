extends PanelContainer

signal pause_closed

@onready var main_vol: HSlider = %MainVol
@onready var sfx_vol: HSlider = %SFXVol
@onready var amb_vol: HSlider = %AmbVol
@onready var ui_mode: CheckButton = %UIMode
@onready var resume: Button = %Resume

func _ready() -> void:
	get_tree().paused = true

func _on_ui_mode_toggled(toggle: bool) -> void:
	GameState.is_debug_ui = toggle

func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_closed.emit()
	queue_free()
