class_name Player
extends CharacterBody2D

@export var start_speed = 150.0
@export var speed = 300.0
@export var jump_speed = -400.0

@onready var body: Body = $Body

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var control_enabled := true

var _speed := 0.0


func _physics_process(delta):
	if not control_enabled:
		return

	velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	var direction = Input.get_axis("left", "right")

	if direction == 0:
		_speed = start_speed
		velocity.x = 0.0
	else:
		_speed = lerp(_speed, speed, delta * 2.0)
		velocity.x = direction * _speed

	move_and_slide()
