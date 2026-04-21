class_name Math


static func constrain_distance_fluid(point: Vector2, anchor: Vector2, distance: float):
	if point.distance_to(anchor) < distance:
		return point
	else:
		return ((point - anchor).normalized() * distance) + anchor


static func constrain_distance_bone(point: Vector2, anchor: Vector2, distance: float):
	return ((point - anchor).normalized() * distance) + anchor


enum ContainmentState { NOT_INSIDE, PARTIALLY_INSIDE, FULLY_INSIDE }


# Pass in the two CollisionShape2D nodes
static func check_circle_in_rect(
	circle_shape: CollisionShape2D, rect_shape: CollisionShape2D
) -> ContainmentState:
	# Get global positions
	var circle_center: Vector2 = circle_shape.global_position
	var radius: float = 0.1

	# Build Rect2 from the RectangleShape2D in global space
	var rect_size: Vector2 = (rect_shape.shape as RectangleShape2D).size * rect_shape.global_scale
	var rect_center: Vector2 = rect_shape.global_position
	var rect := Rect2(rect_center - rect_size / 2.0, rect_size)

	# --- FULLY INSIDE ---
	if (
		circle_center.x - radius >= rect.position.x
		and circle_center.x + radius <= rect.position.x + rect.size.x
		and circle_center.y - radius >= rect.position.y
		and circle_center.y + radius <= rect.position.y + rect.size.y
	):
		return ContainmentState.FULLY_INSIDE

	# --- NOT INSIDE (no overlap at all) ---
	# Find the closest point on the rect to the circle center
	var closest := Vector2(
		clamp(circle_center.x, rect.position.x, rect.position.x + rect.size.x),
		clamp(circle_center.y, rect.position.y, rect.position.y + rect.size.y)
	)
	var dist_sq: float = circle_center.distance_squared_to(closest)

	if dist_sq > radius * radius:
		return ContainmentState.NOT_INSIDE

	# --- PARTIALLY INSIDE ---
	return ContainmentState.PARTIALLY_INSIDE
