extends Node2D

@onready var area: Area2D = $Area2D
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	$Area2D.body_entered.connect(_on_body_connect)
	Events.level_won.connect(_on_level_won)


func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		_on_body_connect(Player.new())


func _on_body_connect(body):
	if not body is Player:
		return
	Events.level_won.emit()


func _on_level_won():
	animation.play("finish")
