class_name Player
extends CharacterBody2D

@export var start_speed = 150.0
@export var speed = 300.0
@export var jump_speed = -400.0
@export var coyote_time = 1.0
@export var max_fall_speed = 500.0

@onready var body: Body = $Body
@onready var audio: PlayerAudio = $PlayerAudio

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var control_enabled := true

var _speed := 0.0
var _is_grounded := false
var _ground_collider: Object

var _window_area_shape: CollisionShape2D

var _is_on_platform := false
var _last_platform_position := Vector2.ZERO
var _last_platform_delta_position := Vector2.ZERO

var _last_position := Vector2.ZERO
var _last_window_position := Vector2.ZERO

var _coyote_timer := 0.0


func _ready():
	$Hurtbox.body_entered.connect(_on_damage_received)
	Events.player_step.connect(_on_player_step)
	_last_position = global_position


func _physics_process(delta):
	if not control_enabled:
		return
	if not is_instance_valid(_window_area_shape):
		return

	_check_ground()

	if not _is_grounded:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		velocity.y = 0.0

	if Input.is_action_just_pressed("jump") and _is_grounded:
		audio.play_jump()
		velocity.y = jump_speed
		_is_grounded = false
		_coyote_timer = 0.0

	var direction = Input.get_axis("left", "right")

	if _is_grounded:
		# ground_control
		if direction == 0:
			_speed = start_speed
			velocity.x = 0.0
		else:
			_speed = lerp(_speed, speed, delta * 3.0)
			velocity.x = direction * _speed
	else:
		# air control
		if direction != 0:
			velocity.x = direction * _speed

	var collision := move_and_collide(velocity * delta, true)
	if collision:
		_push_moving_object(collision, direction)
		_jump_on_spring(collision)

	_prevent_stuck()
	_custom_move_and_slide()

	_handle_platform()

	# update for next frame
	_last_position = global_position
	_last_window_position = _window_area_shape.global_position


func setup(window_area: WindowArea):
	_window_area_shape = window_area.get_node("CollisionShape2D") as CollisionShape2D
	_last_window_position = _window_area_shape.global_position


func _custom_move_and_slide():
	const MAX_SLIDES = 4

	var motion = velocity * get_physics_process_delta_time()

	for i in MAX_SLIDES:
		set_collision_mask_value(Global.WORLD_LAYER, true)
		set_collision_mask_value(Global.VIRTUAL_LAYER, false)
		var real_result := move_and_collide(motion, true)

		set_collision_mask_value(Global.WORLD_LAYER, false)
		set_collision_mask_value(Global.VIRTUAL_LAYER, true)
		var virtual_result := move_and_collide(motion, true)

		var real_has_collision = false
		if real_result and not _is_inside_region(real_result.get_position()):
			real_has_collision = true
		var virtual_has_collision = false
		if virtual_result and _is_inside_region(virtual_result.get_position()):
			virtual_has_collision = true

		var result: KinematicCollision2D
		if real_has_collision and virtual_has_collision:
			if real_result.get_travel().length() < virtual_result.get_travel().length():
				result = real_result
			else:  # real travel > virtual travel
				result = virtual_result
		elif virtual_has_collision:
			result = virtual_result
		elif real_has_collision:
			result = real_result
		else:  # no collision
			position += motion
			break

		# Move up to the collision point
		position += result.get_travel()
		velocity = velocity.slide(result.get_normal())
		motion = result.get_remainder()


func _check_ground():
	const PLAYER_SIZE = 17.0
	var motion = velocity * get_physics_process_delta_time()

	var checker_pos = global_position + Vector2.DOWN * (PLAYER_SIZE + motion.y)
	var checker_inside_region = _is_inside_region(checker_pos)
	var player_inside_region = _is_inside_region(global_position)

	var space_state := get_world_2d().direct_space_state

	var result = null
	if player_inside_region == checker_inside_region:
		var query := PhysicsRayQueryParameters2D.new()
		query.from = global_position
		query.to = checker_pos
		query.collision_mask = Global.VIRTUAL_LAYER if player_inside_region else Global.WORLD_LAYER

		result = space_state.intersect_ray(query)
	else:
		# split collision check in inside and outside
		var outside_region_point = checker_pos if player_inside_region else global_position
		var border_point = Vector2(
			clamp(outside_region_point.x, _region().position.x, _region().end.x),
			clamp(outside_region_point.y, _region().position.y, _region().end.y)
		)

		var query := PhysicsRayQueryParameters2D.new()
		query.from = global_position
		query.to = border_point
		query.hit_from_inside = true
		query.exclude = [get_rid()]
		query.collision_mask = Global.VIRTUAL_LAYER if player_inside_region else Global.WORLD_LAYER

		result = space_state.intersect_ray(query)

		var tquery := PhysicsPointQueryParameters2D.new()
		tquery.position = checker_pos
		tquery.exclude = [get_rid()]
		tquery.collision_mask = Global.WORLD_LAYER if player_inside_region else Global.VIRTUAL_LAYER

		if not result:
			var tresult := space_state.intersect_point(tquery)
			if tresult.size() > 0:
				result = tresult[0]

	if result:
		_coyote_timer = coyote_time
		_is_grounded = true
		_ground_collider = result.collider
	else:
		_is_grounded = false


func _handle_coyote_time():
	if not _is_grounded and _coyote_timer >= 0.0:
		_is_grounded = true
		_coyote_timer -= get_physics_process_delta_time()


func _handle_platform():
	var platform: Node2D
	if _ground_collider and _ground_collider.get_parent().is_in_group("platform"):
		platform = _ground_collider

	# exit platform
	if _is_on_platform and not _is_grounded:
		velocity += _last_platform_delta_position / get_physics_process_delta_time()
		_is_on_platform = false
	# enter platform
	elif platform and not _is_on_platform:
		_last_platform_position = platform.position
		_last_platform_delta_position = Vector2.ZERO
		_is_on_platform = true
	# on platform
	elif platform and _is_on_platform:
		_last_platform_delta_position = platform.position - _last_platform_position
		_last_platform_position = platform.position
		position += _last_platform_delta_position


func _prevent_stuck():
	const STUCK_OFFSET = 16.0

	var window_movement = _window_area_shape.global_position - _last_window_position
	var player_movement = velocity * get_physics_process_delta_time()

	var movement = -window_movement + player_movement
	var offset = sign(movement) * STUCK_OFFSET

	var checker_pos = global_position + movement + offset

	var player_inside_region = _is_inside_region(global_position)
	var checker_inside_region = _is_inside_region(checker_pos)

	if player_inside_region == checker_inside_region:
		# no transition between region
		return

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = checker_pos
	query.collision_mask = Global.WORLD_LAYER if player_inside_region else Global.VIRTUAL_LAYER
	query.exclude = [get_rid()]
	var result := space_state.intersect_point(query)

	if result:
		position -= movement


func _is_inside_region(contact_point: Vector2) -> bool:
	if not is_instance_valid(_window_area_shape):
		return false
	return _region().has_point(contact_point)


func _region() -> Rect2:
	var size: Vector2 = (_window_area_shape.shape as RectangleShape2D).size
	var center: Vector2 = _window_area_shape.global_position
	var region := Rect2(center - size / 2.0, size)
	return region


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


func _on_damage_received(_body):
	Events.player_died.emit()


func _on_player_step():
	if abs(velocity.x) <= 20.0:
		return
	if not _is_grounded:
		return
	if not control_enabled:
		return

	if _is_inside_region(global_position):
		audio.play_ground_step_sound()
	else:
		audio.play_water_step_sound()
