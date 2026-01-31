class_name VisibilityComponent extends Node2D


@export var is_player: bool = false


var parent_entity: Entity = null
var visibility_id: int = -1


func _ready() -> void:
	visibility_id = IdGenerator.generate_visibility_id()
	Visibility.register_visibility_component(self)


func assign_parent_entity(new_parent_entity: Entity) -> void:
	parent_entity = new_parent_entity
