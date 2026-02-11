extends Control

@onready var back_button = $BackButton
@onready var suspect1_container = $Suspect1Container
@onready var suspect1 = $Suspect1Container/Suspect1
@onready var suspect2_container = $Suspect2Container
@onready var suspect2 = $Suspect2Container/Suspect2
@onready var suspect3_container = $Suspect3Container
@onready var suspect3 = $Suspect3Container/Suspect3
@onready var suspect4_container = $Suspect4Container
@onready var suspect4 = $Suspect4Container/Suspect4
@onready var suspect5_container = $Suspect5Container
@onready var suspect5 = $Suspect5Container/Suspect5
@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText
@onready var continue_button = $DialogueBox/ContinueButton
@onready var report_prompt_box = $ReportPromptBox
@onready var yes_button = $ReportPromptBox/YesButton
@onready var no_button = $ReportPromptBox/NoButton
@onready var report_document = $ReportDocument
@onready var confirm_button = $ReportDocument/ConfirmButton
@onready var result_text = $ResultText
@onready var back_to_menu_button = $BackToMenuButton
@onready var game_over_explanation = $GameOverExplanation
@onready var explanation_text = $GameOverExplanation/ExplanationText
@onready var back_to_menu_button_gameover = $GameOverExplanation/BackToMenuButtonGameOver

const HOVER_SCALE = Vector2(1.15, 1.15)
const NORMAL_SCALE = Vector2(1.0, 1.0)
const SCALE_DURATION = 0.2

# Suspect 1 walk animation textures
var suspect1_walk_textures: Array[Texture2D] = []
var suspect1_idle_texture: Texture2D

# Suspect 2 walk animation textures
var suspect2_walk_textures: Array[Texture2D] = []
var suspect2_idle_texture: Texture2D

# Suspect 3 walk animation textures
var suspect3_walk_textures: Array[Texture2D] = []
var suspect3_idle_texture: Texture2D

# Suspect 4 walk animation textures
var suspect4_walk_textures: Array[Texture2D] = []
var suspect4_idle_textures: Array[Texture2D] = []  # Array for animated idle

# Suspect 5 walk animation textures
var suspect5_walk_textures: Array[Texture2D] = []
var suspect5_idle_texture: Texture2D

# Current suspect tracking
var current_suspect: int = 1  # 1, 2, 3, 4, or 5

# Report system
var suspect_checkboxes: Array[Button] = []
var checked_suspects: Array[int] = []
var current_walk_textures: Array[Texture2D] = []
var current_idle_texture: Texture2D
var current_idle_textures: Array[Texture2D] = []  # For suspect 4's animated idle
var current_suspect_sprite: Sprite2D
var current_suspect_container: Node2D

# Animation variables
var walk_animation_timer: float = 0.0
var walk_frame_duration: float = 0.2  # Time per walk frame
var current_walk_frame: int = 0
var is_walking: bool = false

# Footstep sound (using nervous foot clack for everyone)
var footstep_sound: AudioStreamPlayer
var footstep_audio_stream: AudioStream

# Door opening sound
var door_sound: AudioStreamPlayer
var door_audio_stream: AudioStream

# Nervous foot clack sound (for suspect 4 idle and all footsteps)
var foot_clack_sound: AudioStreamPlayer
var foot_clack_audio_stream: AudioStream

# Idle animation variables (for suspect 4)
var idle_animation_timer: float = 0.0
var idle_frame_duration: float = 0.3  # Time per idle frame
var suspect4_idle_frame_duration: float = 0.15  # Faster for suspect 4
var current_idle_frame: int = 0
var is_idling: bool = false

# Typewriter effect
var typewriter_speed: float = 0.03  # Seconds per character
var is_typing: bool = false

# Original position storage
var original_start_x: float = 0.0
var original_y_position: float = 0.0
var is_walking_back: bool = false

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	continue_button.pressed.connect(_on_continue_button_pressed)
	
	# Connect hover signals for scaling
	back_button.mouse_entered.connect(_on_back_button_mouse_entered)
	back_button.mouse_exited.connect(_on_back_button_mouse_exited)
	continue_button.mouse_entered.connect(_on_continue_button_mouse_entered)
	continue_button.mouse_exited.connect(_on_continue_button_mouse_exited)
	
	# Load suspect 1 walk textures
	suspect1_walk_textures.append(load("res://Images/animations/Suspect #1 walk 1.png"))
	suspect1_walk_textures.append(load("res://Images/animations/Suspect #1 walk 2 .png"))
	suspect1_walk_textures.append(load("res://Images/animations/Suspect #1 walk 3.png"))
	suspect1_idle_texture = load("res://Images/animations/Suspect #1 idle 1.png")
	
	# Load suspect 2 walk textures
	suspect2_walk_textures.append(load("res://Images/animations/suspect #2 walk 1.png"))
	suspect2_walk_textures.append(load("res://Images/animations/suspect #2 walk 2.png"))
	suspect2_walk_textures.append(load("res://Images/animations/suspect #2 walk 3.png"))
	suspect2_idle_texture = load("res://Images/animations/suspect #2 idle.png")
	
	# Load suspect 3 walk textures
	suspect3_walk_textures.append(load("res://Images/animations/suspect #3 walk 1.png"))
	suspect3_walk_textures.append(load("res://Images/animations/suspect #3 walk 2.png"))
	suspect3_walk_textures.append(load("res://Images/animations/suspect #3 walk 3.png"))
	suspect3_idle_texture = load("res://Images/animations/suspect #3 idle.png")
	
	# Load suspect 4 walk textures
	suspect4_walk_textures.append(load("res://Images/animations/suspect #4 walk 1.png"))
	suspect4_walk_textures.append(load("res://Images/animations/suspect #4 walk 2.png"))
	suspect4_walk_textures.append(load("res://Images/animations/suspect #4 walk 3.png"))
	# Load suspect 4 idle textures (animated)
	suspect4_idle_textures.append(load("res://Images/animations/suspect #4 idle 1.png"))
	suspect4_idle_textures.append(load("res://Images/animations/suspect #4 idle 2.png"))
	suspect4_idle_textures.append(load("res://Images/animations/suspect #4 idle 3.png"))
	
	# Load suspect 5 walk textures
	suspect5_walk_textures.append(load("res://Images/animations/suspect #5 walk 1.png"))
	suspect5_walk_textures.append(load("res://Images/animations/suspect #5 walk 2.png"))
	suspect5_walk_textures.append(load("res://Images/animations/suspect #5 walk 3.png"))
	suspect5_idle_texture = load("res://Images/animations/suspect #5 idle 1.png")
	
	# Load footstep sound (using nervous foot clack for everyone)
	var clack_path = "res://Images/nervous foot clack.mp3"
	if ResourceLoader.exists(clack_path):
		footstep_audio_stream = load(clack_path)
		if footstep_audio_stream:
			footstep_sound = AudioStreamPlayer.new()
			add_child(footstep_sound)
			footstep_sound.stream = footstep_audio_stream
			footstep_sound.volume_db = 2.0  # Louder so it's clearly audible
			footstep_sound.bus = "Master"  # Ensure it's on the master bus
	
	# Load door opening sound
	var door_path = "res://Images/Door Opening Sound Effect - sound effects (youtube).mp3"
	if ResourceLoader.exists(door_path):
		door_audio_stream = load(door_path)
		if door_audio_stream:
			door_sound = AudioStreamPlayer.new()
			add_child(door_sound)
			door_sound.stream = door_audio_stream
			door_sound.volume_db = 5.0  # Slightly louder
			door_sound.bus = "Master"  # Ensure it's on the master bus
	
	# Load nervous foot clack sound (for suspect 4 idle)
	var clack_path_idle = "res://Images/nervous foot clack.mp3"
	if ResourceLoader.exists(clack_path_idle):
		foot_clack_audio_stream = load(clack_path_idle)
		if foot_clack_audio_stream:
			foot_clack_sound = AudioStreamPlayer.new()
			add_child(foot_clack_sound)
			foot_clack_sound.stream = foot_clack_audio_stream
			foot_clack_sound.volume_db = 2.0  # Louder so it's clearly audible
			foot_clack_sound.bus = "Master"  # Ensure it's on the master bus
	
	# Connect report UI buttons (with null checks)
	if yes_button:
		yes_button.pressed.connect(_on_yes_button_pressed)
	if no_button:
		no_button.pressed.connect(_on_no_button_pressed)
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_button_pressed)
	if back_to_menu_button:
		back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
		back_to_menu_button.mouse_entered.connect(_on_back_to_menu_mouse_entered)
		back_to_menu_button.mouse_exited.connect(_on_back_to_menu_mouse_exited)
	if back_to_menu_button_gameover:
		back_to_menu_button_gameover.pressed.connect(_on_back_to_menu_pressed)
		back_to_menu_button_gameover.mouse_entered.connect(_on_back_to_menu_mouse_entered)
		back_to_menu_button_gameover.mouse_exited.connect(_on_back_to_menu_mouse_exited)
	
	# Hide report UI initially
	if report_prompt_box:
		report_prompt_box.visible = false
	if report_document:
		report_document.visible = false
	if result_text:
		result_text.visible = false
	if back_to_menu_button:
		back_to_menu_button.visible = false
	if game_over_explanation:
		game_over_explanation.visible = false
	
	# Start suspect 1 entrance animation
	start_suspect1_entrance()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mainscene.tscn")

func _on_back_button_mouse_entered() -> void:
	_scale_button(back_button, HOVER_SCALE)

func _on_back_button_mouse_exited() -> void:
	_scale_button(back_button, NORMAL_SCALE)

func _scale_button(button: Button, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", target_scale, SCALE_DURATION)

func _process(delta: float) -> void:
	if is_walking and current_suspect_sprite:
		walk_animation_timer += delta
		if walk_animation_timer >= walk_frame_duration:
			walk_animation_timer = 0.0
			if is_walking_back:
				# Reverse animation - go backwards through frames
				current_walk_frame = (current_walk_frame - 1 + current_walk_textures.size()) % current_walk_textures.size()
			else:
				# Forward animation
				current_walk_frame = (current_walk_frame + 1) % current_walk_textures.size()
			current_suspect_sprite.texture = current_walk_textures[current_walk_frame]
			
			# Play footstep sound on every frame change (using nervous foot clack, slower for suspects)
			if footstep_sound and footstep_sound.stream:
				# Lower pitch to make it slower for suspects
				footstep_sound.pitch_scale = 0.6  # Slower pitch for suspects
				# Play without stopping to allow natural overlap (like suspect 4 on way back)
				footstep_sound.play()
	elif footstep_sound and footstep_sound.playing:
		# Stop footstep sound when not walking
		footstep_sound.stop()
	elif is_idling and current_suspect_sprite and current_idle_textures.size() > 0:
		# Animated idle for suspect 4 (faster animation)
		var frame_duration = suspect4_idle_frame_duration if current_suspect == 4 else idle_frame_duration
		idle_animation_timer += delta
		if idle_animation_timer >= frame_duration:
			idle_animation_timer = 0.0
			current_idle_frame = (current_idle_frame + 1) % current_idle_textures.size()
			current_suspect_sprite.texture = current_idle_textures[current_idle_frame]
			
			# Play nervous foot clack for suspect 4 during idle (way slower)
			if current_suspect == 4 and foot_clack_sound and foot_clack_sound.stream:
				# Much slower pitch for more natural idle sound
				foot_clack_sound.pitch_scale = 0.4  # Way slower
				foot_clack_sound.play()
	elif foot_clack_sound and foot_clack_sound.playing:
		# Stop foot clack sound when suspect 4 stops idling
		foot_clack_sound.stop()

func start_suspect1_entrance() -> void:
	# Play door opening sound and wait for it to finish
	if door_sound and door_sound.stream:
		door_sound.play()
		await door_sound.finished
	
	# Set up suspect 1
	current_suspect = 1
	current_walk_textures = suspect1_walk_textures
	current_idle_texture = suspect1_idle_texture
	current_suspect_sprite = suspect1
	current_suspect_container = suspect1_container
	
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Position suspect 1 off-screen to the right
	var start_x = viewport_size.x + 500  # Off-screen to the right
	var middle_x = viewport_size.x / 2  # Middle of the screen
	var y_position = viewport_size.y * 0.7  # Slightly below center vertically
	
	# Store original position for walking back
	original_start_x = start_x
	original_y_position = y_position
	
	# Set initial position
	suspect1_container.position = Vector2(start_x, y_position)
	suspect1_container.visible = true
	
	# Reset sprite scale (facing right)
	suspect1.scale.x = abs(suspect1.scale.x)
	
	# Start walking animation (forward)
	is_walking_back = false
	is_walking = true
	current_walk_frame = 0
	suspect1.texture = suspect1_walk_textures[0]
	
	# Create tween to move to middle
	var movement_duration = 2.0  # 2 seconds to walk to middle
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(suspect1_container, "position:x", middle_x, movement_duration)
	
	# When movement completes, switch to idle
	await tween.finished
	is_walking = false
	suspect1.texture = suspect1_idle_texture
	
	# Show dialogue box with typewriter effect
	show_dialogue("suspect1")

func show_dialogue(suspect_name: String) -> void:
	# Show the dialogue box
	dialogue_box.visible = true
	
	# Full dialogue text based on suspect
	var full_text: String
	if suspect_name == "suspect1":
		full_text = 'Detective: "Where were you at 8:42 PM during the robbery at Riverside Electronics?"\n\nAlex: "I was walking home from work. My shift at the café ended at 8:30, so I took my usual route along Maple Street. I passed the bus stop around… maybe 8:40? I didn\'t go anywhere near Riverside."'
	elif suspect_name == "suspect2":
		full_text = 'Detective: "Where were you during the incident?"\n\nMaya: "I was studying at the public library. I have exams next week. I checked out at 8:55 — the librarian should confirm it. I didn\'t even know anything happened until I saw the police lights outside."'
	elif suspect_name == "suspect3":
		full_text = 'Detective: "Tell me where you were at the time of the break-in."\n\nDamien: "I was finishing a repair at my shop. A customer\'s car wouldn\'t start, so I stayed late. I clocked out at 9:05. You can check the garage camera if you need."'
	elif suspect_name == "suspect4":
		full_text = 'Detective: "Your location at 8:42 PM, please."\n\nSerena: "Behind the bar at The Silver Fox. Thursdays are packed — I was serving drinks nonstop. Ask anyone who was there; I didn\'t step outside once."'
	elif suspect_name == "suspect5":
		full_text = 'Detective: "Where were you during the incident?"\n\nSuspect 5: "I was at home watching TV. I have witnesses who can confirm I never left my apartment."'
	
	# Start typewriter effect
	await typewriter_text(full_text)

func typewriter_text(text: String) -> void:
	is_typing = true
	dialogue_text.text = ""
	
	for i in range(text.length()):
		if not is_typing:
			break
		dialogue_text.text += text[i]
		await get_tree().create_timer(typewriter_speed).timeout
	
	is_typing = false
	# Show continue button when typing is done
	continue_button.visible = true

func _on_continue_button_pressed() -> void:
	# Hide dialogue box
	dialogue_box.visible = false
	continue_button.visible = false
	
	# Stop idle animation if playing (for suspect 4)
	is_idling = false
	
	# Start walking back animation
	walk_back()

func _on_continue_button_mouse_entered() -> void:
	_scale_button(continue_button, HOVER_SCALE)

func _on_continue_button_mouse_exited() -> void:
	_scale_button(continue_button, NORMAL_SCALE)

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_back_to_menu_mouse_entered() -> void:
	if back_to_menu_button and back_to_menu_button.visible:
		_scale_button(back_to_menu_button, HOVER_SCALE)
	if back_to_menu_button_gameover:
		_scale_button(back_to_menu_button_gameover, HOVER_SCALE)

func _on_back_to_menu_mouse_exited() -> void:
	if back_to_menu_button and back_to_menu_button.visible:
		_scale_button(back_to_menu_button, NORMAL_SCALE)
	if back_to_menu_button_gameover:
		_scale_button(back_to_menu_button_gameover, NORMAL_SCALE)

func walk_back() -> void:
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Special handling for suspect 3 (uses reversed animation when walking back)
	if current_suspect == 3:
		# Flip sprite horizontally to face right (walking back to right)
		current_suspect_sprite.scale.x = abs(current_suspect_sprite.scale.x)
		# Start walking animation (reversed - suspect 3 always uses reversed animations)
		is_walking_back = true
		is_walking = true
		current_walk_frame = suspect3_walk_textures.size() - 1  # Start from last frame, go backwards
		current_suspect_sprite.texture = current_walk_textures[current_walk_frame]
	else:
		# Other suspects: flip sprite horizontally to face right (walking back)
		current_suspect_sprite.scale.x = -abs(current_suspect_sprite.scale.x)
		# Start walking animation (reversed)
		is_walking_back = true
		is_walking = true
		current_walk_frame = current_walk_textures.size() - 1  # Start from last frame
		current_suspect_sprite.texture = current_walk_textures[current_walk_frame]
	
	# Create tween to move back to original position
	var movement_duration = 2.0  # 2 seconds to walk back
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(current_suspect_container, "position:x", original_start_x, movement_duration)
	
	# When movement completes, stop walking
	await tween.finished
	is_walking = false
	is_walking_back = false
	# Set to idle texture (or first idle frame for suspect 4)
	if current_idle_textures.size() > 0:
		current_suspect_sprite.texture = current_idle_textures[0]
	else:
		current_suspect_sprite.texture = current_idle_texture
	
	# Hide current suspect
	current_suspect_container.visible = false
	
	# Chain suspects: 1 -> 2 -> 3 -> 4 -> 5
	if current_suspect == 1:
		await get_tree().create_timer(0.5).timeout  # Small delay before suspect 2 enters
		start_suspect2_entrance()
	elif current_suspect == 2:
		await get_tree().create_timer(0.5).timeout  # Small delay before suspect 3 enters
		start_suspect3_entrance()
	elif current_suspect == 3:
		await get_tree().create_timer(0.5).timeout  # Small delay before suspect 4 enters
		start_suspect4_entrance()
	elif current_suspect == 4:
		await get_tree().create_timer(0.5).timeout  # Small delay before suspect 5 enters
		start_suspect5_entrance()
	elif current_suspect == 5:
		# All suspects done, show report prompt
		await get_tree().create_timer(0.5).timeout
		show_report_prompt()

func start_suspect2_entrance() -> void:
	# Play door opening sound and wait for it to finish
	if door_sound and door_sound.stream:
		door_sound.play()
		await door_sound.finished
	
	# Set up suspect 2
	current_suspect = 2
	current_walk_textures = suspect2_walk_textures
	current_idle_texture = suspect2_idle_texture
	current_suspect_sprite = suspect2
	current_suspect_container = suspect2_container
	
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Position suspect 2 off-screen to the right
	var start_x = viewport_size.x + 500  # Off-screen to the right
	var middle_x = viewport_size.x / 2  # Middle of the screen
	var y_position = viewport_size.y * 0.7  # Slightly below center vertically
	
	# Store original position for walking back
	original_start_x = start_x
	original_y_position = y_position
	
	# Set initial position
	suspect2_container.position = Vector2(start_x, y_position)
	suspect2_container.visible = true
	
	# Reset sprite scale (facing right)
	suspect2.scale.x = abs(suspect2.scale.x)
	
	# Start walking animation (forward)
	is_walking_back = false
	is_walking = true
	current_walk_frame = 0
	suspect2.texture = suspect2_walk_textures[0]
	
	# Create tween to move to middle
	var movement_duration = 2.0  # 2 seconds to walk to middle
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(suspect2_container, "position:x", middle_x, movement_duration)
	
	# When movement completes, switch to idle
	await tween.finished
	is_walking = false
	suspect2.texture = suspect2_idle_texture
	
	# Show dialogue box with typewriter effect
	show_dialogue("suspect2")

func start_suspect3_entrance() -> void:
	# Play door opening sound and wait for it to finish
	if door_sound and door_sound.stream:
		door_sound.play()
		await door_sound.finished
	
	# Set up suspect 3
	current_suspect = 3
	current_walk_textures = suspect3_walk_textures
	current_idle_texture = suspect3_idle_texture
	current_suspect_sprite = suspect3
	current_suspect_container = suspect3_container
	
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Position suspect 3 off-screen to the right (same as other suspects)
	var start_x = viewport_size.x + 500  # Off-screen to the right
	var middle_x = viewport_size.x / 2  # Middle of the screen
	var y_position = viewport_size.y * 0.7  # Slightly below center vertically
	
	# Store original position for walking back
	original_start_x = start_x
	original_y_position = y_position
	
	# Set initial position
	suspect3_container.position = Vector2(start_x, y_position)
	suspect3_container.visible = true
	
	# Flip sprite horizontally to face left (walking from right to center)
	suspect3.scale.x = -abs(suspect3.scale.x)
	
	# Start walking animation (REVERSED - suspect 3 uses reversed animations)
	is_walking_back = true  # Use reversed animation even when walking forward
	is_walking = true
	current_walk_frame = suspect3_walk_textures.size() - 1  # Start from last frame
	suspect3.texture = suspect3_walk_textures[current_walk_frame]
	
	# Create tween to move to middle
	var movement_duration = 2.0  # 2 seconds to walk to middle
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(suspect3_container, "position:x", middle_x, movement_duration)
	
	# When movement completes, switch to idle
	await tween.finished
	is_walking = false
	is_walking_back = false
	suspect3.texture = suspect3_idle_texture
	
	# Show dialogue box with typewriter effect
	show_dialogue("suspect3")

func start_suspect4_entrance() -> void:
	# Play door opening sound and wait for it to finish
	if door_sound and door_sound.stream:
		door_sound.play()
		await door_sound.finished
	
	# Set up suspect 4
	current_suspect = 4
	current_walk_textures = suspect4_walk_textures
	current_idle_textures = suspect4_idle_textures
	current_suspect_sprite = suspect4
	current_suspect_container = suspect4_container
	
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Position suspect 4 off-screen to the right
	var start_x = viewport_size.x + 500  # Off-screen to the right
	var middle_x = viewport_size.x / 2  # Middle of the screen
	var y_position = viewport_size.y * 0.7  # Slightly below center vertically
	
	# Store original position for walking back
	original_start_x = start_x
	original_y_position = y_position
	
	# Set initial position
	suspect4_container.position = Vector2(start_x, y_position)
	suspect4_container.visible = true
	
	# Reset sprite scale (facing right)
	suspect4.scale.x = abs(suspect4.scale.x)
	
	# Start walking animation (forward)
	is_walking_back = false
	is_walking = true
	is_idling = false
	current_walk_frame = 0
	suspect4.texture = suspect4_walk_textures[0]
	
	# Create tween to move to middle
	var movement_duration = 2.0  # 2 seconds to walk to middle
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(suspect4_container, "position:x", middle_x, movement_duration)
	
	# When movement completes, switch to animated idle
	await tween.finished
	is_walking = false
	is_idling = true
	current_idle_frame = 0
	suspect4.texture = suspect4_idle_textures[0]
	
	# Show dialogue box with typewriter effect
	show_dialogue("suspect4")

func start_suspect5_entrance() -> void:
	# Play door opening sound and wait for it to finish
	if door_sound and door_sound.stream:
		door_sound.play()
		await door_sound.finished
	
	# Set up suspect 5
	current_suspect = 5
	current_walk_textures = suspect5_walk_textures
	current_idle_texture = suspect5_idle_texture
	current_suspect_sprite = suspect5
	current_suspect_container = suspect5_container
	
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	
	# Position suspect 5 off-screen to the right
	var start_x = viewport_size.x + 500  # Off-screen to the right
	var middle_x = viewport_size.x / 2  # Middle of the screen
	var y_position = viewport_size.y * 0.7  # Slightly below center vertically
	
	# Store original position for walking back
	original_start_x = start_x
	original_y_position = y_position
	
	# Set initial position
	suspect5_container.position = Vector2(start_x, y_position)
	suspect5_container.visible = true
	
	# Reset sprite scale (facing right)
	suspect5.scale.x = abs(suspect5.scale.x)
	
	# Start walking animation (forward)
	is_walking_back = false
	is_walking = true
	is_idling = false
	current_walk_frame = 0
	suspect5.texture = suspect5_walk_textures[0]
	
	# Create tween to move to middle
	var movement_duration = 2.0  # 2 seconds to walk to middle
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(suspect5_container, "position:x", middle_x, movement_duration)
	
	# When movement completes, switch to idle
	await tween.finished
	is_walking = false
	suspect5.texture = suspect5_idle_texture
	
	# Show dialogue box with typewriter effect
	show_dialogue("suspect5")

func show_report_prompt() -> void:
	if report_prompt_box:
		report_prompt_box.visible = true

func _on_yes_button_pressed() -> void:
	if report_prompt_box:
		report_prompt_box.visible = false
	show_report_document()

func _on_no_button_pressed() -> void:
	# Restart interrogation introduction scene
	get_tree().change_scene_to_file("res://scenes/interrogation_introduction.tscn")

func show_report_document() -> void:
	if report_document:
		report_document.visible = true
		create_report_ui()
		# Speed up background music
		if BackgroundMusic and BackgroundMusic.audio_player:
			BackgroundMusic.audio_player.pitch_scale = 1.5  # Play 50% faster

func create_report_ui() -> void:
	var suspect_list = $ReportDocument/ScrollContainer/SuspectList
	if not suspect_list:
		return
	# Clear existing children
	for child in suspect_list.get_children():
		child.queue_free()
	
	suspect_checkboxes.clear()
	checked_suspects.clear()
	
	# Suspect data: [suspect_number, name, idle_texture]
	var suspects_data = [
		[1, "Alex", suspect1_idle_texture],
		[2, "Maya", suspect2_idle_texture],
		[3, "Damien", suspect3_idle_texture],
		[4, "Serena", suspect4_idle_textures[0]],  # Use first idle frame
		[5, "Jordan", suspect5_idle_texture]
	]
	
	for suspect_data in suspects_data:
		var suspect_num = suspect_data[0]
		var suspect_name = suspect_data[1]
		var idle_texture = suspect_data[2]
		
		# Create VBoxContainer for each suspect (vertical layout: image, name, checkbox)
		var suspect_container = VBoxContainer.new()
		suspect_container.add_theme_constant_override("separation", 10)
		suspect_container.custom_minimum_size = Vector2(150, 180)
		suspect_container.alignment = BoxContainer.ALIGNMENT_CENTER
		
		# Create TextureRect for suspect image
		var suspect_image = TextureRect.new()
		suspect_image.texture = idle_texture
		suspect_image.custom_minimum_size = Vector2(80, 80)
		suspect_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		suspect_container.add_child(suspect_image)
		
		# Create Label for suspect name
		var name_label = Label.new()
		name_label.text = suspect_name
		name_label.add_theme_font_size_override("font_size", 18)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		suspect_container.add_child(name_label)
		
		# Create clickable square (Button)
		var square_button = Button.new()
		square_button.name = "SquareButton"
		square_button.custom_minimum_size = Vector2(40, 40)
		square_button.pressed.connect(_on_square_clicked.bind(suspect_num, square_button))
		# Style the button to look like a square
		var square_style = StyleBoxFlat.new()
		square_style.bg_color = Color(0.8, 0.8, 0.8, 1.0)
		square_style.border_width_left = 2
		square_style.border_width_top = 2
		square_style.border_width_right = 2
		square_style.border_width_bottom = 2
		square_style.border_color = Color(0.3, 0.3, 0.3, 1.0)
		square_button.add_theme_stylebox_override("normal", square_style)
		square_button.add_theme_stylebox_override("hover", square_style)
		square_button.add_theme_stylebox_override("pressed", square_style)
		square_button.text = ""  # No text, just a square
		suspect_checkboxes.append(square_button)  # Store reference
		suspect_container.add_child(square_button)
		
		suspect_list.add_child(suspect_container)

func _on_square_clicked(suspect_num: int, square_button: Button) -> void:
	# Toggle check state
	if suspect_num in checked_suspects:
		# Uncheck
		checked_suspects.erase(suspect_num)
		# Remove green check style
		var square_style = StyleBoxFlat.new()
		square_style.bg_color = Color(0.8, 0.8, 0.8, 1.0)
		square_style.border_width_left = 2
		square_style.border_width_top = 2
		square_style.border_width_right = 2
		square_style.border_width_bottom = 2
		square_style.border_color = Color(0.3, 0.3, 0.3, 1.0)
		square_button.add_theme_stylebox_override("normal", square_style)
		square_button.add_theme_stylebox_override("hover", square_style)
		square_button.add_theme_stylebox_override("pressed", square_style)
		square_button.text = ""
	else:
		# Check
		checked_suspects.append(suspect_num)
		# Add green check style
		var check_style = StyleBoxFlat.new()
		check_style.bg_color = Color.GREEN
		check_style.border_width_left = 2
		check_style.border_width_top = 2
		check_style.border_width_right = 2
		check_style.border_width_bottom = 2
		check_style.border_color = Color(0.2, 0.6, 0.2, 1.0)
		square_button.add_theme_stylebox_override("normal", check_style)
		square_button.add_theme_stylebox_override("hover", check_style)
		square_button.add_theme_stylebox_override("pressed", check_style)
		square_button.text = "✓"
		square_button.add_theme_font_size_override("font_size", 24)

func _on_confirm_button_pressed() -> void:
	# Check if suspects 2 and 4 are checked (and only them)
	var correct_suspects = [2, 4]
	var has_correct = true
	var has_wrong = false
	
	# Check if all correct suspects are checked
	for suspect in correct_suspects:
		if suspect not in checked_suspects:
			has_correct = false
			break
	
	# Check if any wrong suspects are checked
	for suspect in checked_suspects:
		if suspect not in correct_suspects:
			has_wrong = true
			break
	
	# Show result
	report_document.visible = false
	result_text.visible = true
	
	if has_correct and not has_wrong and checked_suspects.size() == 2:
		result_text.text = "YOU WON"
		result_text.modulate = Color.GREEN
		result_text.visible = true
		# Wait a moment to show the win message, then transition to bibliography
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/actual bibliography.tscn")
	else:
		result_text.text = "GAME OVER"
		result_text.modulate = Color.RED
		result_text.visible = true
		# Show explanation text box
		if game_over_explanation and explanation_text:
			game_over_explanation.visible = true
			explanation_text.text = "After reviewing the interrogations, two individuals stood out as the most suspicious. Suspect #2 repeatedly avoided eye contact during questioning, a classic sign of discomfort or possible dishonesty. Meanwhile, Suspect #4 displayed clear physical anxiety, tapping her foot throughout the interview in a way that suggested nervousness under pressure.\n\n\nIn contrast, the remaining suspects maintained steady composure, showing no visible signs of stress or deception. Their body language remained calm and consistent, making them less likely to be involved."

