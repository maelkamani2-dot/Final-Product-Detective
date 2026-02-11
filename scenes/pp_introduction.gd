extends Control

@onready var continue_button = $ContinueButton

const HOVER_SCALE = Vector2(1.15, 1.15)
const NORMAL_SCALE = Vector2(1.0, 1.0)
const SCALE_DURATION = 0.2

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	
	# Connect hover signals for scaling
	continue_button.mouse_entered.connect(_on_continue_button_mouse_entered)
	continue_button.mouse_exited.connect(_on_continue_button_mouse_exited)
	
	# Start text at the top
	$IntroductionText.scroll_to_line(0)

func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainscene.tscn")

func _on_continue_button_mouse_entered() -> void:
	_scale_button(continue_button, HOVER_SCALE)

func _on_continue_button_mouse_exited() -> void:
	_scale_button(continue_button, NORMAL_SCALE)

func _scale_button(button: Button, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", target_scale, SCALE_DURATION)


