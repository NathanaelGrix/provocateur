extends Node

@export var doors: Array[NodePath]

var current_index := 0


func _ready():
	for i in doors.size():
		var door = get_node(doors[i])
		door.lock()
		
	activate_door(0)
	
func activate_door(index: int):
	if index >= doors.size():
		return
		
	if index > 0:
		get_node(doors[index -1]).hide_next_door_ind()
		
	var door = get_node(doors[index])
	door.unlock()
	door.show_next_door_ind()
	current_index = index
	
func unlock_next_door():
	activate_door(current_index +1)
