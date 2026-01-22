class_name SyncSprite2D
extends Node2D

@onready var sprite := get_parent() as Sprite2D

var _virtual_sprite: Sprite2D


func _ready():
	assert(sprite)

	_virtual_sprite = sprite.duplicate()

	await get_tree().root.ready
	SceneManager.main.virtual_viewport.add_child(_virtual_sprite)


func _process(_delta):
	_virtual_sprite.global_position = sprite.global_position
