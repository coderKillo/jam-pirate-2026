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

var _feet_position := Vector2.ZERO
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
	var start = anchor.global_position
	var ray_direction = Vector2(sign(player.velocity.x) * look_ahead, length).normalized()
	var end = start + ray_direction * length
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.exclude = [player]
	var result = space_state.intersect_ray(query)
	if result:
		_feet_position = result.position
		_on_ground = true
		Events.player_step.emit()
	else:
		_feet_position = end
		_on_ground = false


func _process(_delta):
	global_position = Vector2.ZERO

	feet.global_position = _feet_position

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
