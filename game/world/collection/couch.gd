extends Node2D

@onready var area: Area2D = $Area2D


func _ready():
	$Area2D.body_entered.connect(_on_body_connect)


func _on_body_connect(body):
	if not body is Player:
		return
	Events.level_won.emit()
