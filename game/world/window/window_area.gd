class_name WindowArea
extends Area2D


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: PhysicsBody2D):
	body_to_world(body, false)
	var hurtbox = body.get_node_or_null("Hurtbox")
	if hurtbox:
		hutbox_to_world(hurtbox, false)


func _on_body_exited(body: PhysicsBody2D):
	body_to_world(body, true)
	var hurtbox = body.get_node_or_null("Hurtbox")
	if hurtbox:
		hutbox_to_world(hurtbox, true)


static func body_to_world(body: PhysicsBody2D, real_world: bool):
	body.set_collision_layer_value(Global.VIRTUAL_LAYER, !real_world)
	body.set_collision_layer_value(Global.WORLD_LAYER, real_world)
	body.set_collision_mask_value(Global.VIRTUAL_LAYER, !real_world)
	body.set_collision_mask_value(Global.WORLD_LAYER, real_world)


static func hutbox_to_world(hurtbox: Area2D, real_world: bool):
	hurtbox.set_collision_mask_value(Global.VIRTUAL_DMG_LAYER, !real_world)
	hurtbox.set_collision_mask_value(Global.REAL_DMG_LAYER, real_world)


static func hitbox_to_world(hitbox: StaticBody2D, real_world: bool):
	hitbox.set_collision_layer_value(Global.VIRTUAL_DMG_LAYER, !real_world)
	hitbox.set_collision_layer_value(Global.REAL_DMG_LAYER, real_world)


static func set_monitor_layer(body: PhysicsBody2D, value: bool):
	body.set_collision_layer_value(Global.WINDOW_LAYER, value)
