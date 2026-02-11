extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var bibliography_button = $VBoxContainer/BibliographyButton
@onready var quit_button = $VBoxContainer/QuitButton

const HOVER_SCALE = Vector2(1.15, 1.15)
const NORMAL_SCALE = Vector2(1.0, 1.0)
const SCALE_DURATION = 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	bibliography_button.pressed.connect(_on_bibliography_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Connect hover signals for scaling
	start_button.mouse_entered.connect(_on_start_button_mouse_entered)
	start_button.mouse_exited.connect(_on_start_button_mouse_exited)
	bibliography_button.mouse_entered.connect(_on_bibliography_button_mouse_entered)
	bibliography_button.mouse_exited.connect(_on_bibliography_button_mouse_exited)
	quit_button.mouse_entered.connect(_on_quit_button_mouse_entered)
	quit_button.mouse_exited.connect(_on_quit_button_mouse_exited)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/pp_introduction.tscn")

func _on_bibliography_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/actual bibliography.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_mouse_entered() -> void:
	_scale_button(start_button, HOVER_SCALE)

func _on_start_button_mouse_exited() -> void:
	_scale_button(start_button, NORMAL_SCALE)

func _on_bibliography_button_mouse_entered() -> void:
	_scale_button(bibliography_button, HOVER_SCALE)

func _on_bibliography_button_mouse_exited() -> void:
	_scale_button(bibliography_button, NORMAL_SCALE)

func _on_quit_button_mouse_entered() -> void:
	_scale_button(quit_button, HOVER_SCALE)

func _on_quit_button_mouse_exited() -> void:
	_scale_button(quit_button, NORMAL_SCALE)

func _scale_button(button: Button, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", target_scale, SCALE_DURATION)
