class_name Gym
extends Level


func _ready():
	assert(virtual_world)
	assert(real_world)
	assert(player)
	assert(tv)
	assert(couch)

	Events.level_setup.emit()

	# load with main scene if run with "run current scene"
	if not is_instance_valid(SceneManager.main):
		_reload()

	Events.level_lose.connect(_lose)


func _win():
	Events.level_won.emit()


func _lose():
	_reload()


func _reload():
	await get_tree().root.ready
	SceneManager.load_game_scene()
	SceneManager.current_level = SceneManager.scene_resource.gym.instantiate()
	SceneManager.main.level_container.call_deferred("add_child", SceneManager.current_level)
