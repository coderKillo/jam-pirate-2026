class_name Level
extends Node2D

@export var level_index := 0

@onready var virtual_world := $VirtualWorld
@onready var real_world := $RealWorld
@onready var player := $Player as Player
@onready var tv := $RealWorld/TV
@onready var couch := $VirtualWorld/Couch
@onready var camera := $StaticCamera as Camera2D


func _ready():
	assert(virtual_world)
	assert(real_world)
	assert(player)
	assert(tv)
	assert(couch)

	Events.level_setup.emit()

	# load with main scene if run with "run current scene"
	if not is_instance_valid(SceneManager.main):
		await get_tree().root.ready
		SceneManager.load_level(level_index)


func _win():
	Events.level_won.emit()


func _lose():
	Events.level_lose.emit()
