extends Node2D

@export var fade_time := 1.0

@export_category("References")
@export var player: Player
@export var jump_area: Area2D
@export var window_move_area: StaticBody2D

var infos: Array[Sprite2D]

var _current_info: int = -1


func _ready():
	for child in get_children():
		if child is Sprite2D:
			child.modulate.a = 0.0
			infos.append(child)

	_show_next()

	Events.tv_collected.connect(_on_tv_collected)


func _process(_delta):
	for index in range(infos.size()):
		var alpha = 0.0
		if index == _current_info:
			alpha = 1.0
		infos[index].modulate.a = lerp(infos[index].modulate.a, alpha, 0.1)


func _physics_process(_delta):
	if player.velocity.x > 0:
		_trigger(0)
	if jump_area.has_overlapping_bodies():
		_trigger(1)
	if window_move_area.get_collision_layer_value(Global.VIRTUAL_LAYER):
		_trigger(3)


func _trigger(info: int):
	if info == _current_info:
		_show_next()


func _show_next():
	_current_info += 1
	if _current_info >= infos.size():
		return


func _on_tv_collected():
	_trigger(2)
