class_name Main
extends Control

@export var level_container: Node
@export var gui: Control

@onready var window_display: WindowDisplay = $WindowCanvesLayer/WindowDisplay
@onready var virtual_world_container: Node2D = $VirtualViewPort/Container
@onready var virtual_player: VirtualPlayer = $VirtualViewPort/VirtualPlayer
@onready var music: AudioStreamPlayer = $BackgroundMusic

var _virtual_world: Node2D

var _tween: Tween


func _ready():
	Events.level_setup.connect(_on_setup_level)
	Events.level_won.connect(_on_level_won)
	Events.level_lose.connect(_on_level_lose)
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
	virtual_player.show()

	_copy_real_world_to_virtual_world()

	window_display.enable = false
	window_display.global_position = window_display.disable_position

	music.stream_paused = false


func _on_level_won():
	var level := SceneManager.current_level as Level

	level.player.control_enabled = false
	level.player.hide()
	virtual_player.hide()

	window_display.enable = false

	_tween = get_tree().create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(
		window_display, "global_position", level.couch.global_position + Vector2.UP * 50.0, 0.5
	)

	$LevelWonSound.play()
	music.stream_paused = true


func _on_level_lose():
	$LevelLosSound.play()


func _on_tv_collected():
	window_display.get_node("AnimationPlayer").play("on")
	window_display.global_position = SceneManager.current_level.tv.global_position
	$TvCollectedSound.play()
	Events.start_wave.emit(window_display.global_position)


func _on_player_died():
	Events.level_lose.emit()


func _copy_real_world_to_virtual_world():
	for child in SceneManager.current_level.real_world.get_children():
		if child.is_in_group("spring"):
			var virtual_spring = child.make_copy()
			_virtual_world.add_child(virtual_spring)
			virtual_spring.position = child.position

		if child.is_in_group("platform"):
			var virtual_platform = child.make_copy()
			_virtual_world.add_child(virtual_platform)
			virtual_platform.position = child.position
