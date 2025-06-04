extends AudioStreamPlayer3D

@export_category("Audio")

@export var sounds_a: Array[AudioStream]
@export var sounds_b: Array[AudioStream]

@export_category("Pitch")

@export var pitch: float = 1
@export var pitch_variation: float = 0.05

func _play_natural(samples: Array[AudioStream]):
	var sample = samples.pick_random()
	# pitch
	pitch_scale = randf_range(pitch - pitch_variation, pitch + pitch_variation)
	print(pitch_scale)
	stream = sample
	play()
	
func play_naturally_a():
	_play_natural(sounds_a)
	
func play_naturally_b():
	_play_natural(sounds_b)
