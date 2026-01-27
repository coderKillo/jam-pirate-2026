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

	var collision := move_and_collide(velocity * delta, true)
	if collision:
		_push_moving_object(collision, direction)
		_jump_on_spring(collision)

	move_and_slide()


func _push_moving_object(collision: KinematicCollision2D, direction: float):
	var collider := collision.get_collider()
	if not collider.is_in_group("moveable"):
		return
	velocity.x /= 2.0
	var push_dir := -collision.get_normal()
	var target_velocity := velocity.max(direction * _speed * 0.5 * Vector2.RIGHT)
	var push_force = target_velocity.dot(push_dir) - collider.linear_velocity.dot(push_dir)

	collider.apply_impulse(push_dir * push_force)


func _jump_on_spring(collision: KinematicCollision2D):
	var collider := collision.get_collider()
	if not collider.is_in_group("spring"):
		return
	if collision.get_normal().y >= 0:
		return
	collider.play_animation()
	velocity.y = -velocity.y * collider.power_multiply
