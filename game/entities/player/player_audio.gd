class_name PlayerAudio
extends Node2D

@onready var water_step_audio_queue: AudioQueue = $WaterStepsQueue
@onready var ground_step_audio_queue: AudioQueue = $GroundStepsQueue
@onready var jump_sound: AudioStreamPlayer = $JumpSound


func play_water_step_sound():
	water_step_audio_queue.play()


func play_ground_step_sound():
	ground_step_audio_queue.play()


func play_jump():
	jump_sound.play()
