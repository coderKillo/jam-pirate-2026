class_name Main
extends Control

@export var level_container: Node
@export var gui: Control

@onready var window_display: WindowDisplay = $WindowCanvesLayer/WindowDisplay
@onready var virtual_world_container: Node2D = $VirtualViewPort/Container
@onready var virtual_player: VirtualPlayer = $VirtualViewPort/VirtualPlayer

var _virtual_world: Node2D

var _tween: Tween


func _ready():
	Events.level_setup.connect(_on_setup_level)
	Events.level_won.connect(_on_level_won)
	Events.tv_collected.connect(_on_tv_collected)
	Events.player_died.connect(_on_player_died)


func _on_setup_level():
	if is_instance_valid(_tween):
		_tween.stop()

	if is_instance_valid(_virtual_world):
		virtual_world_container.remove_child(_virtual_world)
		_virtual_world.queue_free()

	SceneManager.current_level.virtual_world.hide()

	_virtual_world = SceneManager.current_level.virtual_world.duplicate()
	_virtual_world.show()
	virtual_world_container.add_child(_virtual_world)
	_virtual_world.position = $World.position

	virtual_player.set_player(SceneManager.current_level.player)

	window_display._enable = false
	window_display.global_position = window_display.disable_position


func _on_level_won():
	var level := SceneManager.current_level as Level

	level.player.control_enabled = false

	window_display._enable = false

	_tween = get_tree().create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(window_display, "global_position", level.couch.global_position, 0.5)
	_tween.tween_property(level.player, "global_position:x", level.couch.global_position.x, 0.2)
	(
		_tween
		. tween_property(
			level.player, "global_position:y", level.player.global_position.y + 25, 0.5
		)
		. set_trans(Tween.TRANS_ELASTIC)
		. set_ease(Tween.EASE_OUT)
	)


func _on_tv_collected():
	window_display.global_position = SceneManager.current_level.tv.global_position
	window_display._enable = true


func _on_player_died():
	Events.level_lose.emit()
