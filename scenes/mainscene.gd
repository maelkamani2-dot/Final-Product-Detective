extends Node2D

@onready var book = $Book
@onready var player = $Player
@onready var interrogation_zone = $InterrogationZone
@onready var background = $"environnement baclground"
@onready var instructions_panel = $InstructionsLayer/InstructionsPanel

var was_touching_zone: bool = false
var is_hovering_book: bool = false
var is_hovering_zone: bool = false

var base_viewport_size = Vector2(1920, 1080)
var scale_factor = Vector2(1.0, 1.0)
var has_scaled = false
var last_viewport_size = Vector2.ZERO

func _ready() -> void:
	# Connect the input_event signal from the book
	if book:
		book.input_event.connect(_on_book_input_event)
	
	# Scale everything to fit the screen (deferred to ensure viewport is ready)
	call_deferred("scale_to_fit_screen")

func scale_to_fit_screen() -> void:
	if has_scaled:
		return
	
	var viewport = get_viewport()
	if not viewport:
		return
	
	var viewport_size = viewport.get_visible_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		viewport_size = base_viewport_size
	
	scale_factor = viewport_size / base_viewport_size
	
	# Scale background to fill screen
	if background and background.texture:
		var bg_texture_size = background.texture.get_size()
		var bg_scale_x = viewport_size.x / bg_texture_size.x
		var bg_scale_y = viewport_size.y / bg_texture_size.y
		# Use the larger scale to ensure it fills the screen
		var bg_scale = max(bg_scale_x, bg_scale_y)
		background.scale = Vector2(bg_scale, bg_scale)
		# Center the background
		background.position = viewport_size / 2
	
	# Keep player, book, and interrogation zone at original size and position
	# (They remain unchanged from the scene file - no scaling)
	
	# Scale instructions panel so text stays readable in fullscreen
	if instructions_panel:
		var ui_scale = minf(scale_factor.x, scale_factor.y)
		instructions_panel.scale = Vector2(ui_scale, ui_scale)
	
	last_viewport_size = viewport_size
	has_scaled = true

func _process(_delta: float) -> void:
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size if viewport else base_viewport_size
	# Re-run scaling when viewport size changes (e.g. fullscreen toggle)
	if viewport_size != last_viewport_size and viewport_size.x > 0 and viewport_size.y > 0:
		has_scaled = false
	if not has_scaled:
		scale_to_fit_screen()
	if player and interrogation_zone:
		# Check if player is currently touching the interrogation zone
		var is_touching = is_player_touching_zone()
		
		if is_touching and not was_touching_zone:
			was_touching_zone = true
			# Transition to interrogation introduction scene when first touching the zone
			get_tree().change_scene_to_file("res://scenes/interrogation_introduction.tscn")
		elif not is_touching:
			was_touching_zone = false
	
	# Check if mouse is hovering over interrogation zone
	if interrogation_zone:
		var mouse_pos = get_global_mouse_position()
		var zone_pos = interrogation_zone.position
		var zone_size = Vector2(150, 150)
		var zone_rect = Rect2(zone_pos - zone_size / 2, zone_size)
		
		var currently_hovering = zone_rect.has_point(mouse_pos)
		
		if currently_hovering and not is_hovering_zone:
			# Mouse just entered
			is_hovering_zone = true
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		elif not currently_hovering and is_hovering_zone:
			# Mouse just exited
			is_hovering_zone = false
			# Only reset cursor if not hovering over book
			if not is_hovering_book:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	# Check if mouse is hovering over book (using the collision shape for accurate detection)
	if book:
		var mouse_pos = get_global_mouse_position()
		var book_pos = book.global_position
		var book_size = Vector2(100, 120)  # Match the collision shape size
		var book_rect = Rect2(book_pos - book_size / 2, book_size)
		
		var currently_hovering = book_rect.has_point(mouse_pos)
		
		if currently_hovering and not is_hovering_book:
			# Mouse just entered
			is_hovering_book = true
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		elif not currently_hovering and is_hovering_book:
			# Mouse just exited
			is_hovering_book = false
			# Only reset cursor if not hovering over zone
			if not is_hovering_zone:
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func is_player_touching_zone() -> bool:
	if not player or not interrogation_zone:
		return false
	
	var zone_pos = interrogation_zone.position
	var zone_size = Vector2(150, 150)
	var zone_rect = Rect2(zone_pos - zone_size / 2, zone_size)
	
	# Use a smaller hitbox for the player (50% of visual size)
	var player_size = Vector2(
		(player.texture.get_width() * player.scale.x * 0.5) if player.texture else 10,
		(player.texture.get_height() * player.scale.y * 0.5) if player.texture else 10
	)
	var player_rect = Rect2(player.position - player_size / 2, player_size)
	
	return zone_rect.intersects(player_rect)

func _on_book_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Check if it's a mouse button press (left click)
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# Open the learning scene when clicking on the book
			get_tree().change_scene_to_file("res://scenes/learning_scene.tscn")
