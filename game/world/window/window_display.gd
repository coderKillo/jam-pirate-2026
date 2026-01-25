class_name WindowDisplay
extends Node2D

@export var disable_position := Vector2(5000, 5000)

var _enable := false


func _input(event):
	if _enable:
		if event is InputEventMouseMotion:
			global_position += event.relative
