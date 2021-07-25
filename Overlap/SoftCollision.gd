extends Area2D

const ACCELERATION = 400

func get_push_vector():
	var areas = get_overlapping_areas()
	if areas.size() == 0:
		return Vector2.ZERO
	var push_vector_direction = areas[0].global_position.direction_to(global_position)
	return push_vector_direction * ACCELERATION
