extends Sprite2D

@export var speed: float = 200.0

var footstep_sound: AudioStreamPlayer
var footstep_audio_stream: AudioStream
var footstep_timer: float = 0.0
var footstep_interval: float = 0.15  # Match suspect 4's idle animation speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load footstep sound (using nervous foot clack)
	var clack_path = "res://Images/nervous foot clack.mp3"
	if ResourceLoader.exists(clack_path):
		footstep_audio_stream = load(clack_path)
		if footstep_audio_stream:
			footstep_sound = AudioStreamPlayer.new()
			add_child(footstep_sound)
			footstep_sound.stream = footstep_audio_stream
			footstep_sound.volume_db = 2.0  # Louder so it's clearly audible
			footstep_sound.bus = "Master"  # Ensure it's on the master bus

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Get input direction from arrow keys
	var direction = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	
	# Normalize movement to maintain consistent speed
	if direction.length() > 0:
		direction = direction.normalized()
	# Ensure no vertical movement
	direction.y = 0
	
	# Flip sprite when moving left (invert for left movement)
	if direction.x < 0:
		flip_h = true
	elif direction.x > 0:
		flip_h = false
	
	# Move the character
	position += direction * speed * delta
	
	# Play footstep sound when moving (matching suspect 4's idle animation speed)
	if direction.length() > 0:
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
			footstep_timer = 0.0
			if footstep_sound and footstep_sound.stream:
				# Higher pitch to make it faster for player
				footstep_sound.pitch_scale = 1.2  # Faster pitch for player
				if not footstep_sound.playing:
					footstep_sound.play()
	elif footstep_sound and footstep_sound.playing:
		# Stop footstep sound when not moving
		footstep_sound.stop()
		footstep_timer = 0.0
