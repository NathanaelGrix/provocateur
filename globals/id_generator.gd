extends Node


var next_visibility_id: int = 0


func generate_visibility_id() -> int:
	next_visibility_id += 1
	return next_visibility_id - 1
