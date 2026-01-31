class_name Entity extends CharacterBody2D


enum Faction {
	NOT_SET,
	PLAYER,
	COWBOY,
	ALIEN,
}


@export var visibility_component: VisibilityComponent = null
@export var health_component: HealthComponent = null
@export var faction: Faction = Faction.NOT_SET


var entity_id: int = -1
var aggro_against: Array[Faction] = []


func _ready() -> void:
	entity_id = IdGenerator.generate_entity_id()
	assert(visibility_component != null, "All entities must have a visibility component! Make sure to assign it to the \"visibility_component\" variable")
	assert(visibility_component != null, "All entities must have a health component! Make sure to assign it to the \"health_component\" variable")
	assert(faction != Faction.NOT_SET, "You must set a faction alliance for all entities!")
	visibility_component.assign_parent_entity(self)
