class_name VirtualPlayer
extends Node2D

var _player: Player
var _body: Line2D
var _head: Sprite2D
var _legs: Array[Line2D]


func set_player(player: Player):
	for child in get_children():
		remove_child(child)
	_legs.clear()

	_player = player

	_body = _player.body.line.duplicate()
	add_child(_body)

	_head = _player.body.head.duplicate()
	add_child(_head)

	for leg in _player.body.legs:
		var leg_copy = leg.line.duplicate()
		_legs.append(leg_copy)
		add_child(leg_copy)


func _process(_delta):
	if not is_instance_valid(_player):
		return

	_head.global_position = _player.body.head.global_position
	_sync_line(_player.body.line, _body)
	for i in _legs.size():
		_sync_line(_player.body.legs[i].line, _legs[i])


func _sync_line(a: Line2D, b: Line2D):
	for i in a.get_point_count():
		b.set_point_position(i, a.get_point_position(i))
