extends RigidBody2D

@export var power_multiply := 1.3

@onready var _animation: AnimatedSprite2D = $AnimatedSprite2D

var virtual_copy: AnimatedSprite2D


func _ready():
	_animation.animation_finished.connect(_on_animation_finished)


func make_copy() -> Node2D:
	virtual_copy = _animation.duplicate()
	return virtual_copy


func play_animation():
	_animation.play("jump")


func _process(_delta):
	if not is_instance_valid(virtual_copy):
		return

	virtual_copy.global_position = global_position
	virtual_copy.animation = _animation.animation
	virtual_copy.set_frame_and_progress(_animation.frame, _animation.frame_progress)


func _on_animation_finished():
	_animation.play("idle")
