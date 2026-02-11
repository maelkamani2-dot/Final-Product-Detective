extends Control

@onready var page_content = $BookContainer/PageContainer/CurrentPage/PageContent
@onready var page_number_label = $BookContainer/PageContainer/CurrentPage/PageNumber
@onready var current_page = $BookContainer/PageContainer/CurrentPage
@onready var book_container = $BookContainer
@onready var close_button = $CloseButton

var current_page_index: int = 0
var is_animating: bool = false
var is_book_opening: bool = true

const HOVER_SCALE = Vector2(1.15, 1.15)
const NORMAL_SCALE = Vector2(1.0, 1.0)
const SCALE_DURATION = 0.2

var pages: Array[String] = [
	"""[center][b]Reading the Silent Truth: A Detective's Guide to Nonverbal Cues[/b][/center]

[i]Words lie. Bodies rarely do. Every gesture, glance, and posture tells a story — if you know how to read it.[/i]

[font_size=24][b]The Face[/b][/font_size]

Tight lips? Someone's holding back.

Flash of a smile that disappears? False calm.

Rapid blinking? Stress or fear.

Eyes shifting left or right? They may be recalling truth—or inventing it.

Too much eye contact? Masking fear with aggression.""",
	
	"""[font_size=24][b]Hands[/b][/font_size]

Hidden hands? Secrets.

Rubbing palms or fingers? Nervous energy.

Touching neck or collar? Anxiety or lying.

Open palms? Honesty or pleading.

Clenched fists? Anger held in check.""",
	
	"""[font_size=24][b]Body[/b][/font_size]

Leaning forward? Interest or challenge.

Leaning back? Discomfort or detachment.

Crossed arms? Defensive.

Feet pointing to the door? They want out.

Hands on hips? Dominance or impatience.""",
	
	"""[font_size=24][b]Voice[/b][/font_size]

Sudden pitch change? Emotion breaking through.

Pausing before answering? Fabrication.

Speaking too fast? Nervousness.

Monotone? Concealing feelings.

"Uh" or "Um"? Hesitation, self-editing.""",
	
	"""[font_size=24][b]Distance & Orientation[/b][/font_size]

Too close? Intimidation.

Too far? Fear or distrust.

Body angled away? Disinterest or hostility.

Mirroring? Rapport or empathy.

[font_size=18][i]Remember: One signal alone is nothing. Patterns reveal the truth. Watch, listen, and learn — the body will always tell the story the words try to hide.[/i][/font_size]"""
]

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Connect hover signals for scaling
	close_button.mouse_entered.connect(_on_close_button_mouse_entered)
	close_button.mouse_exited.connect(_on_close_button_mouse_exited)
	
	update_page_display()
	animate_book_open()

func _input(event: InputEvent) -> void:
	if is_animating or is_book_opening:
		return
	
	if event.is_action_pressed("ui_left") or (event is InputEventKey and event.keycode == KEY_LEFT):
		previous_page()
	elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.keycode == KEY_RIGHT):
		next_page()

func next_page() -> void:
	if current_page_index < pages.size() - 1:
		current_page_index += 1
		animate_page_turn(1)

func previous_page() -> void:
	if current_page_index > 0:
		current_page_index -= 1
		animate_page_turn(-1)

func animate_page_turn(direction: int) -> void:
	is_animating = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Slide out current page
	tween.tween_property(current_page, "modulate:a", 0.0, 0.3)
	tween.tween_property(current_page, "position:x", direction * 150.0, 0.3)
	
	await tween.finished
	
	# Update content and page number
	page_content.text = pages[current_page_index]
	page_number_label.text = "Page %d of %d" % [current_page_index + 1, pages.size()]
	
	# Reset position from opposite side
	current_page.position.x = -direction * 150.0
	current_page.modulate.a = 0.0
	
	# Slide in new page
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(current_page, "modulate:a", 1.0, 0.3)
	tween2.tween_property(current_page, "position:x", 0.0, 0.3)
	
	await tween2.finished
	is_animating = false

func update_page_display() -> void:
	page_content.text = pages[current_page_index]
	page_number_label.text = "Page %d of %d" % [current_page_index + 1, pages.size()]

func animate_book_open() -> void:
	# Start with book closed (small, rotated, and pages hidden)
	book_container.scale = Vector2(0.3, 0.3)
	book_container.rotation_degrees = -90.0
	book_container.modulate.a = 0.0
	
	# Hide page content initially (book is closed)
	current_page.modulate.a = 0.0
	
	# First: Fade in the closed book
	var tween1 = create_tween()
	tween1.tween_property(book_container, "modulate:a", 1.0, 0.3)
	await tween1.finished
	
	# Second: Rotate to show it's opening (from closed position to open)
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_BACK)
	tween2.tween_property(book_container, "rotation_degrees", 0.0, 0.6)
	tween2.tween_property(book_container, "scale", Vector2(1.0, 1.0), 0.6)
	await tween2.finished
	
	# Third: Fade in the page content (book opens)
	var tween3 = create_tween()
	tween3.tween_property(current_page, "modulate:a", 1.0, 0.4)
	await tween3.finished
	
	# Animation complete, allow navigation
	is_book_opening = false

func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainscene.tscn")

func _on_close_button_mouse_entered() -> void:
	_scale_button(close_button, HOVER_SCALE)

func _on_close_button_mouse_exited() -> void:
	_scale_button(close_button, NORMAL_SCALE)

func _scale_button(button: Button, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", target_scale, SCALE_DURATION)
