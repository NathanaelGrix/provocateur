extends Node


## Every this many frames the visibility should be updated
const UPDATE_FREQENCY: int = 5

const IS_VISIBLE: String = "is"
const NOT_VISIBLE: String = "not"


var visible_components: Dictionary[int, VisibilityComponent] = {}
## visibility ID -> IS_VISIBLE/NOT_VISIBLE -> visibility ID
var is_visible_mapping: Dictionary[int, Dictionary] = {}
## updated tick -> array of arrays of 2 visibility IDs whos link has not been checked
var last_updated: Dictionary[int, Array] = { 0: [] }
var current_tick: int = UPDATE_FREQENCY
var detector: RayCast2D = null


func _ready() -> void:
	detector = RayCast2D.new()
	detector.set_collision_mask_value(1, false)
	detector.set_collision_mask_value(2, true)
	detector.hit_from_inside = true
	add_child(detector)


func _physics_process(_delta: float) -> void:
	current_tick += 1
	for id_arr in last_updated[0]:
		process_id_arr(id_arr)

	var tick_to_update = current_tick - UPDATE_FREQENCY
	if last_updated.has(tick_to_update):
		for id_arr in last_updated[tick_to_update]:
			process_id_arr(id_arr)
		last_updated[current_tick] = last_updated[tick_to_update]
		last_updated.erase(tick_to_update)

	if not last_updated[0].is_empty():
		var prev_ticks = range(current_tick - UPDATE_FREQENCY + 1, current_tick + 1)
		var desired_size = last_updated[0].size()
		for prev_tick in prev_ticks:
			if last_updated.has(prev_tick):
				desired_size += last_updated[prev_tick].size()
			else:
				last_updated[prev_tick] = []
		desired_size = desired_size / UPDATE_FREQENCY
		var curr_chunk_start = 0
		for prev_tick in prev_ticks:
			var curr_arr = last_updated[prev_tick]
			if prev_tick == prev_ticks.back():
				curr_arr.append_array(last_updated[0].slice(curr_chunk_start))
			else:
				curr_arr.append_array(
					last_updated[0].slice(curr_chunk_start, curr_chunk_start + desired_size)
				)
				curr_chunk_start += desired_size
		last_updated[0].clear()


func process_id_arr(id_arr: Array) -> void:
	var first_id = id_arr[0]
	var second_id = id_arr[1]
	var first_component = visible_components[first_id]
	var second_component = visible_components[second_id]
	detector.global_position = first_component.global_position
	detector.target_position = detector.to_local(second_component.global_position)
	detector.force_raycast_update()
	var detected_distance = (first_component.global_position - second_component.global_position).length()
	var was_previously_visible = is_visible_mapping[first_id][IS_VISIBLE].has(second_id)
	# Only modify the state if actually necessary
	if detector.is_colliding() and was_previously_visible:
		is_visible_mapping[first_id][NOT_VISIBLE][second_id] = true
		is_visible_mapping[second_id][NOT_VISIBLE][first_id] = true
		is_visible_mapping[first_id][IS_VISIBLE].erase(second_id)
		is_visible_mapping[second_id][IS_VISIBLE].erase(first_id)
	elif not detector.is_colliding():
		is_visible_mapping[first_id][IS_VISIBLE][second_id] = detected_distance
		is_visible_mapping[second_id][IS_VISIBLE][first_id] = detected_distance
		is_visible_mapping[first_id][NOT_VISIBLE].erase(second_id)
		is_visible_mapping[second_id][NOT_VISIBLE].erase(first_id)


func register_visibility_component(new_component: VisibilityComponent) -> void:
	is_visible_mapping[new_component.visibility_id] = {}
	is_visible_mapping[new_component.visibility_id][NOT_VISIBLE] = {}
	is_visible_mapping[new_component.visibility_id][IS_VISIBLE] = {}
	for other_id in visible_components.keys():
		is_visible_mapping[new_component.visibility_id][NOT_VISIBLE][other_id] = true
		is_visible_mapping[other_id][NOT_VISIBLE][new_component.visibility_id] = true
		last_updated[0].append([other_id, new_component.visibility_id])
	visible_components[new_component.visibility_id] = new_component
	var cleanup_callable = Callable(self, "_on_component_exiting").bind(new_component)
	new_component.tree_exiting.connect(cleanup_callable)


func is_line_of_sight_between(first_entity: Entity, second_entity: Entity) -> bool:
	var first_id = first_entity.visibility_component.visibility_id
	var second_id = second_entity.visibility_component.visibility_id
	return is_visible_mapping[first_id][IS_VISIBLE].has(second_id)


func get_all_entities_visible_to(entity: Entity) -> Array:
	var visible_ids = is_visible_mapping[entity.visibility_component.visibility_id][IS_VISIBLE].keys()
	return visible_ids.map(func (visibility_id): return visible_components[visibility_id].parent_entity)


## Looks at all the entities visible from the given entity. Then filters for only the visible
## entities which belong to a faction the given entity is aggro against. Returns the closest
## entity among those.
func get_nearest_aggroed_entity(from_entity: Entity) -> Entity:
	var min_distance = null
	var nearest_entity = null
	for other_id in is_visible_mapping[from_entity.visibility_component.visibility_id][IS_VISIBLE].keys():
		# If this other ID is an entity from a faction the from_entity is aggro'd against
		if from_entity.aggro_against_factions[visible_components[other_id].parent_entity.faction]:
			var distance = is_visible_mapping[from_entity.visibility_component.visibility_id][IS_VISIBLE][other_id]
			if min_distance == null or distance < min_distance:
				nearest_entity = visible_components[other_id].parent_entity
				min_distance = distance
	return nearest_entity


func _on_component_exiting(component: VisibilityComponent) -> void:
	is_visible_mapping.erase(component.visibility_id)
	for other_id in visible_components.keys():
		if other_id != component.visibility_id:
			is_visible_mapping[other_id][NOT_VISIBLE].erase(component.visibility_id)
			is_visible_mapping[other_id][IS_VISIBLE].erase(component.visibility_id)
	for tick in last_updated.keys():
		last_updated[tick] = last_updated[tick].filter(func (id_arr): return not component.visibility_id in id_arr)
	visible_components.erase(component.visibility_id)
