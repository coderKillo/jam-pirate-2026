extends Node

@onready var scene_resource: SceneResource = preload("res://base/core/scenes/scenes.tres")

var main: Main
var current_level: Node

var _transition: Control
var _in_transition = false


func _ready():
	Events.level_won.connect(_on_game_won)
	Events.level_lose.connect(_on_game_lose)

	var transition = scene_resource.transition.instantiate()
	add_child(transition)
	_transition = transition.get_node("Transition")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_pause_game()


func load_game_scene():
	main = scene_resource.main_scene.instantiate()
	var tree = get_tree()
	var current_scene = tree.current_scene

	tree.root.add_child(main)
	tree.root.remove_child(current_scene)
	current_scene.queue_free()
	tree.current_scene = main


func load_main_menu():
	if _in_transition:
		return

	_in_transition = true
	await _do_transition(true)

	get_tree().change_scene_to_packed(scene_resource.main_menu)
	main = null

	await _do_transition(false)
	_in_transition = false


func reload_level():
	load_level(GameState.get_current_level())


func advance_level():
	var next_level = GameState.get_current_level() + 1
	if next_level >= level_size():
		return

	load_level(next_level)


func level_size() -> int:
	return scene_resource.levels.size()


func load_level(level: int):
	assert(level < level_size())
	GameState.set_current_level(level)
	load_level_scene(scene_resource.levels[level])


func load_level_scene(level_scene: PackedScene):
	if _in_transition:
		return

	_in_transition = true
	await _do_transition(true)

	if not is_instance_valid(main):
		load_game_scene()

	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null

	current_level = level_scene.instantiate()

	if is_instance_valid(main.level_container):
		main.level_container.call_deferred("add_child", current_level)
	else:
		main.call_deferred("add_child", current_level)

	await _do_transition(false)
	_in_transition = false


func _on_game_won():
	if not is_instance_valid(main):
		return

	var scene = scene_resource.win_menu.instantiate()
	main.gui.add_child(scene)


func _on_game_lose():
	if not is_instance_valid(main):
		return

	var scene = scene_resource.lose_menu.instantiate()
	main.gui.add_child(scene)


func _pause_game():
	if not is_instance_valid(main):
		return

	var scene = scene_resource.pause_menu.instantiate()
	main.gui.add_child(scene)


# wait for transition to be finished
func _do_transition(transition_in: bool) -> void:
	const SHADER_HEIGHT_IN = 1.0
	const SHADER_HEIGHT_OUT = -1.0
	var transition_time = 1.0

	var tween := get_tree().create_tween()
	var to = SHADER_HEIGHT_IN if transition_in else SHADER_HEIGHT_OUT
	var from = SHADER_HEIGHT_OUT if transition_in else SHADER_HEIGHT_IN
	var duration = transition_time / 2.0

	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_transition, "material:shader_parameter/height", to, duration).from(from)

	await tween.finished
