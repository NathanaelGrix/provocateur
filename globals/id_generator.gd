extends Node


var next_visibility_id: int = 0
var next_entity_id: int = 0


func generate_entity_id() -> int:
	next_entity_id += 1
	return next_entity_id - 1


func generate_visibility_id() -> int:
	next_visibility_id += 1
	return next_visibility_id - 1
