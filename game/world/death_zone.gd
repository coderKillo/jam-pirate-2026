extends Area2D


func _ready():
	body_entered.connect(_on_body_connect)


func _on_body_connect(body):
	if not body is Player:
		return
	Events.player_died.emit()
