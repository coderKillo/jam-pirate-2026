extends Node2D

@export var player: Player

var _body: Line2D
var _head: Sprite2D
var _legs: Array[Line2D]


func _ready():
	assert(player)

	_body = player.body.line.duplicate()
	add_child(_body)

	_head = player.body.head.duplicate()
	add_child(_head)

	for leg in player.body.legs:
		var leg_copy = leg.line.duplicate()
		_legs.append(leg_copy)
		add_child(leg_copy)


func _process(_delta):
	_head.global_position = player.body.head.global_position
	_sync_line(player.body.line, _body)
	for i in _legs.size():
		_sync_line(player.body.legs[i].line, _legs[i])


func _sync_line(a: Line2D, b: Line2D):
	for i in a.get_point_count():
		b.set_point_position(i, a.get_point_position(i))
