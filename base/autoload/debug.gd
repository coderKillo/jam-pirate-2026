extends Node2D

var _points: Array[Vector2] = []


func draw_points(pts: Array[Vector2]) -> void:
	_points = pts
	queue_redraw()


func _ready():
	z_index = 99


func _draw() -> void:
	for p in _points:
		draw_circle(p, 5.0, Color.RED)
