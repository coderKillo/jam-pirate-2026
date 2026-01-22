extends Node2D

@export var height := 20.0
@export var tail_length := 25.0
@export var head_length := 12.0
@export var animation_smoothing := 3.0
@export var body_segments := 12.0

@export var legs: Array[Legs]

@onready var head: Node2D = $Head
@onready var hip: Node2D = $Hip
@onready var shoulder: Node2D = $Shoulder
@onready var tail: Node2D = $Tail
@onready var tail_ground_anchor: Node2D = $TailGroundAnchor
@onready var line: Line2D = $Line2D
@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var leg_step_timer: Timer = $LegStepTimer

@onready var player: Player = get_parent()

var _current_head_offset := Vector2.ZERO
var _head_offset := Vector2.ZERO
var _direction := Vector2.LEFT
var _leg_index := 0


func _ready():
	global_position = Vector2.ZERO
	_head_offset = Vector2(head_length, height)

	for i in range(body_segments):
		line.add_point(Vector2.ZERO)

	for leg in legs:
		leg.player = player

	leg_step_timer.timeout.connect(_on_step_timer_timout)
	leg_step_timer.start()


func _physics_process(_delta):
	var space_rid = get_world_2d().space
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var query = PhysicsRayQueryParameters2D.create(
		player.global_position, player.global_position + Vector2.DOWN * tail_length
	)
	var result = space_state.intersect_ray(query)
	if result:
		tail_ground_anchor.global_position = result.position
	else:
		tail_ground_anchor.global_position = tail.global_position + Vector2.DOWN * tail_length


func _process(delta):
	global_position = Vector2.ZERO

	if abs(player.velocity.x) > 0.0:
		_direction = player.velocity.normalized()

	if _is_running():
		_head_offset = Vector2(sign(_direction.x) * head_length, 0.0)
	else:
		_head_offset = Vector2(sign(_direction.x) * head_length, -height)

	_current_head_offset = lerp(_current_head_offset, _head_offset, delta * animation_smoothing)
	head.global_position = player.global_position + _current_head_offset

	_move_to_axis(shoulder, player, "x", delta)
	_move_to_axis(shoulder, head, "y", delta)
	_constrain_joints(shoulder, head, head_length)

	_move_to_axis(hip, player, "x", delta)
	_move_to_axis(hip, player, "y", delta)
	_constrain_joints(hip, shoulder, height)

	_move_to_axis(tail, tail_ground_anchor, "y", delta)
	_constrain_joints(tail, hip, tail_length)

	_update_line()


func _constrain_joints(a: Node2D, b: Node2D, length: float):
	a.global_position = Math.constrain_distance_fluid(a.global_position, b.global_position, length)


func _move_to_axis(a: Node2D, b: Node2D, axis: String, delta: float):
	match axis.to_lower():
		"x":
			a.global_position.x = lerp(
				a.global_position.x, b.global_position.x, animation_smoothing * delta
			)
		"y":
			a.global_position.y = lerp(
				a.global_position.y, b.global_position.y, animation_smoothing * delta
			)
		_:
			pass


func _update_line():
	path.curve.set_point_position(0, head.global_position)
	path.curve.set_point_position(1, shoulder.global_position)
	path.curve.set_point_position(2, hip.global_position)
	path.curve.set_point_position(3, tail.global_position)

	for i in range(body_segments):
		path_follow.progress_ratio = i / body_segments
		line.set_point_position(i, path_follow.global_position)


func _on_step_timer_timout():
	_leg_index = (_leg_index + 1) % legs.size()
	legs[_leg_index].update_feed_position = true


func _is_running() -> bool:
	return abs(player.velocity.length()) > player.start_speed
