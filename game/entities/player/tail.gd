extends Line2D

@export var num_segments := 4
@export var distance := 10.0
@export var offset := Vector2.ZERO


func _ready():
	for i in num_segments:
		add_point(Vector2.ZERO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	# global_position = Vector2.ZERO
	# var start_position = get_parent().global_position + offset
	# set_point_position(0, start_position)
	# for i in range(1, get_point_count()):
	# 	var point_position = Math.constrain_distance(
	# 		get_point_position(i), get_point_position(i - 1), distance
	# 	)
	# 	var target_height = start_position.y + (width / 2.0) * (i / float(num_segments))
	# 	point_position.y = lerp(point_position.y, target_height, _delta * 3.0)
	# 	set_point_position(i, point_position)
