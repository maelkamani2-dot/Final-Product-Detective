extends Node

var audio_player: AudioStreamPlayer

func _ready() -> void:
	# Create audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Load the detective audio file
	var audio_path = "res://Images/detective audio.mp3"
	if ResourceLoader.exists(audio_path):
		var audio_stream = load(audio_path)
		if audio_stream:
			audio_player.stream = audio_stream
			audio_player.volume_db = 0.0  # Adjust volume as needed (0 = full volume)
			# Set loop mode
			if audio_stream is AudioStream:
				audio_stream.loop = true
			# Connect finished signal to restart if loop doesn't work
			audio_player.finished.connect(_on_audio_finished)
			audio_player.play()

func _on_audio_finished() -> void:
	# Restart playback if it stops (backup in case loop doesn't work)
	if audio_player and audio_player.stream:
		audio_player.play()

