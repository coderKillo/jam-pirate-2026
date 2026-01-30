class_name AudioQueue
extends Node2D

@export var steams: Array[AudioStream]
@export var queue_size := 4
@export var throttle_time := 0.3

@export_range(0.01, 4.0) var pitch_min := 1.0
@export_range(0.01, 4.0) var pitch_max := 1.0

var _timer := 0.0


func _ready():
	for i in range(queue_size):
		var audio_source = AudioStreamPlayer.new()
		audio_source.volume_db = -6.0
		audio_source.bus = "SFX"
		add_child(audio_source)


func play():
	if _timer <= throttle_time:
		return
	_timer = 0

	for child in get_children():
		var audio_source := child as AudioStreamPlayer
		if audio_source.playing:
			continue
		audio_source.stream = steams.pick_random()
		audio_source.pitch_scale = randf_range(pitch_min, pitch_max)
		audio_source.play()
		break


func _process(delta):
	_timer += delta
