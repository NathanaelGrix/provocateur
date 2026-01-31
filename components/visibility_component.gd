class_name VisibilityComponent extends Node2D


@export var is_player: bool = false


var parent_entity: Node2D = null
var visibility_id: int = -1


func _ready() -> void:
	add_to_group("visible")
	assign_parent_entity.call_deferred()
	visibility_id = IdGenerator.generate_visibility_id()


func assign_parent_entity() -> void:
	parent_entity = get_parent()
	Visibility.register_visibility_component(self)
