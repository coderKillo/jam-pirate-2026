class_name Math


static func constrain_distance_fluid(point: Vector2, anchor: Vector2, distance: float):
	if point.distance_to(anchor) < distance:
		return point
	else:
		return ((point - anchor).normalized() * distance) + anchor


static func constrain_distance_bone(point: Vector2, anchor: Vector2, distance: float):
	return ((point - anchor).normalized() * distance) + anchor
