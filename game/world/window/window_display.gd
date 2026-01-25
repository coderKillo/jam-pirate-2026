class_name WindowDisplay
extends Node2D

@export var disable_position := Vector2(5000, 5000)

var _enable := false


func _ready():
	Events.enable_view.connect(_on_enable_view)


func _process(_delta):
	if _enable:
		global_position = get_global_mouse_position()


func _on_enable_view(enable: bool):
	_enable = enable
