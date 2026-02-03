extends Area2D


func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: PhysicsBody2D):
	print("Body entered: ", body)
	body.set_collision_layer_value(Global.VIRTUAL_LAYER, true)
	body.set_collision_layer_value(Global.WORLD_LAYER, false)
	body.set_collision_mask_value(Global.VIRTUAL_LAYER, true)
	body.set_collision_mask_value(Global.WORLD_LAYER, false)

	var hurtbox = body.get_node_or_null("Hurtbox")
	if hurtbox:
		hurtbox.set_collision_mask_value(Global.VIRTUAL_DMG_LAYER, true)
		hurtbox.set_collision_mask_value(Global.REAL_DMG_LAYER, false)


func _on_body_exited(body: PhysicsBody2D):
	body.set_collision_layer_value(Global.VIRTUAL_LAYER, false)
	body.set_collision_layer_value(Global.WORLD_LAYER, true)
	body.set_collision_mask_value(Global.VIRTUAL_LAYER, false)
	body.set_collision_mask_value(Global.WORLD_LAYER, true)

	var hurtbox = body.get_node_or_null("Hurtbox")
	if hurtbox:
		hurtbox.set_collision_mask_value(Global.VIRTUAL_DMG_LAYER, false)
		hurtbox.set_collision_mask_value(Global.REAL_DMG_LAYER, true)
