class_name Legs
extends Node2D

@export var length := 25.0
@export var look_ahead := 10.0
@export var anchor: Node2D

@onready var feet: Node2D = $Feet
@onready var joint: Node2D = $Joint
@onready var line: Line2D = $Line2D

var update_feed_position := false
var player: Player

var _ref_object: Node2D
var _feet_position := Vector2.ZERO  # relative feet position to _ref_object
var _on_ground := false


func _ready():
	assert(anchor)
	line.add_point(anchor.global_position)
	line.add_point(joint.global_position)
	line.add_point(feet.global_position)


func _physics_process(_delta):
	if not update_feed_position:
		return
	update_feed_position = false

	if anchor.global_position.distance_to(_feet_position) < length and _on_ground:
		return

	var space_rid = get_world_2d().space
	var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
	var start = Vector2(anchor.global_position.x, player.global_position.y)
	var ray_direction = Vector2(sign(player.velocity.x) * look_ahead, length).normalized()
	var end = start + ray_direction * length
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.exclude = [player]
	query.collision_mask = (
		Global.VIRTUAL_LAYER if player._is_inside_region(end) else Global.WORLD_LAYER
	)
	var result = space_state.intersect_ray(query)
	var new_feet_position = _feet_position
	if result:
		_ref_object = result.collider
		_on_ground = true
		new_feet_position = result.position - _ref_object.global_position
	else:
		_ref_object = null
		_on_ground = false
		new_feet_position = end

	if new_feet_position != _feet_position:
		_feet_position = new_feet_position
		Events.player_step.emit()


func _process(_delta):
	global_position = Vector2.ZERO

	feet.global_position = _feet_position
	if _ref_object:
		feet.global_position += _ref_object.global_position

	joint.global_position = Math.constrain_distance_bone(
		joint.global_position, feet.global_position, length / 2.0
	)

	joint.global_position = Math.constrain_distance_bone(
		joint.global_position, anchor.global_position, length / 2.0
	)

	feet.global_position = Math.constrain_distance_bone(
		feet.global_position, joint.global_position, length / 2.0
	)

	line.points[0] = anchor.global_position
	line.points[1] = joint.global_position
	line.points[2] = feet.global_position
