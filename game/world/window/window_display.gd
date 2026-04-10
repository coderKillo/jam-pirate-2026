class_name WindowDisplay
extends Node2D

@export var disable_position := Vector2(5000, 5000)
@export var bounding_box: Rect2
@export var virtual_camera: Camera2D

var _enable := false


func _unhandled_input(event):
	if _enable:
		if event is InputEventMouseMotion:
			var new_position = global_position + (event.relative * AppSettings.mouse_sensitifity())
			global_position = new_position.clamp(bounding_box.position, bounding_box.end)
			virtual_camera.global_position = global_position
