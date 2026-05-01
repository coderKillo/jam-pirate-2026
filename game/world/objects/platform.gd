@tool
class_name Platform
extends Path2D

@export_category("Setup")
@export var length := 50.0:
	set(value):
		length = value
		update_line()

@export var direction := Vector2.RIGHT:
	set(value):
		direction = value
		update_line()

@export_range(0.0, 1.0) var start_position := 0.0:
	set(value):
		start_position = value
		update_follow()

@export_category("Settings")
@export var speed := 50.0
@export var in_real_world := true
@export var in_virtual_world := true
@export var has_top_traps := true
@export var has_bottom_traps := true
@export var move_in_real_world := true
@export var move_in_virtual_world := true

@onready var _path_follow: PathFollow2D = $PathFollow2D
@onready var _virtual_sprite: Sprite2D = $AnimatableBody2D/VirtualSprite
@onready var _real_spirte: Sprite2D = $AnimatableBody2D/RealSprite
@onready var _body: AnimatableBody2D = $AnimatableBody2D
@onready var _hitbox: StaticBody2D = $AnimatableBody2D/Hitbox
@onready var _line: Line2D = $Line2D

var virtual_copy: Sprite2D

var _path_follow_direction := 1


func _ready():
	if in_real_world and in_virtual_world:
		_hitbox.set_collision_layer_value(Global.VIRTUAL_DMG_LAYER, true)
		_hitbox.set_collision_layer_value(Global.REAL_DMG_LAYER, true)
		_body.set_collision_layer_value(Global.VIRTUAL_LAYER, true)
		_body.set_collision_layer_value(Global.WORLD_LAYER, true)
		_body.set_collision_mask_value(Global.VIRTUAL_LAYER, true)
		_body.set_collision_mask_value(Global.WORLD_LAYER, true)
		WindowArea.set_monitor_layer(_body, false)
	elif in_real_world:
		WindowArea.set_monitor_layer(_body, false)
		WindowArea.body_to_world(_body, true)
		WindowArea.hitbox_to_world(_hitbox, true)
		_virtual_sprite.hide()
	elif in_virtual_world:
		WindowArea.set_monitor_layer(_body, false)
		WindowArea.body_to_world(_body, false)
		WindowArea.hitbox_to_world(_hitbox, false)
		_real_spirte.hide()

	_real_spirte.get_node("TrapsTop").visible = has_top_traps
	_virtual_sprite.get_node("TrapsTop").visible = has_top_traps
	_hitbox.get_node("CollisionTop").disabled = not has_top_traps

	_real_spirte.get_node("TrapsBottom").visible = has_bottom_traps
	_virtual_sprite.get_node("TrapsBottom").visible = has_bottom_traps
	_hitbox.get_node("CollisionBottom").disabled = not has_bottom_traps

	update_line()
	update_follow()


func _process(delta):
	if Engine.is_editor_hint():
		return

	if not move_in_real_world and not WindowDisplay.is_inside_region(global_position):
		return
	if not move_in_virtual_world and WindowDisplay.is_inside_region(global_position):
		return

	var new_progress = _path_follow.progress + _path_follow_direction * speed * delta

	if new_progress >= length:
		new_progress = (length - 0.1)
		_path_follow_direction = -1
	elif new_progress <= 0.0:
		new_progress = 0.0
		_path_follow_direction = 1

	_path_follow.progress = new_progress

	if virtual_copy:
		virtual_copy.global_position = _virtual_sprite.global_position


func make_copy() -> Node2D:
	virtual_copy = _virtual_sprite.duplicate()
	virtual_copy.global_position = _virtual_sprite.global_position
	_virtual_sprite.hide()

	return virtual_copy


func update_line():
	var start = -(direction.normalized() * length / 2.0)
	var end = direction.normalized() * length / 2.0

	var _curve := Curve2D.new()
	_curve.add_point(start)
	_curve.add_point(end)
	curve = _curve

	if is_instance_valid(_line):
		_line.clear_points()
		_line.add_point(start)
		_line.add_point(end)


func update_follow():
	if is_instance_valid(_path_follow):
		_path_follow.progress = start_position * length
