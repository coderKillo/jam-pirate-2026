extends Area2D


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: PhysicsBody2D):
	body.set_collision_layer_value(Global.VIRTUAL_LAYER, true)
	body.set_collision_layer_value(Global.WORLD_LAYER, false)
	body.set_collision_mask_value(Global.VIRTUAL_LAYER, true)
	body.set_collision_mask_value(Global.WORLD_LAYER, false)


func _on_body_exited(body: PhysicsBody2D):
	body.set_collision_layer_value(Global.VIRTUAL_LAYER, false)
	body.set_collision_layer_value(Global.WORLD_LAYER, true)
	body.set_collision_mask_value(Global.VIRTUAL_LAYER, false)
	body.set_collision_mask_value(Global.WORLD_LAYER, true)
