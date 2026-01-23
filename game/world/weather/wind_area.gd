extends Area2D

@export var wind_power := 100


func _physics_process(delta):
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			body.velocity.y += delta * -wind_power
