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
var aggro_against_factions: Dictionary[Faction, bool] = {}
var aggro_target: Entity = null


func _ready() -> void:
	entity_id = IdGenerator.generate_entity_id()
	for fac in Faction.values():
		aggro_against_factions[fac] = false
	assert(visibility_component != null, "All entities must have a visibility component! Make sure to assign it to the \"visibility_component\" variable")
	assert(visibility_component != null, "All entities must have a health component! Make sure to assign it to the \"health_component\" variable")
	assert(faction != Faction.NOT_SET, "You must set a faction alliance for all entities!")
	visibility_component.assign_parent_entity(self)


func _physics_process(_delta: float) -> void:
	if aggro_target != null and aggro_target.is_inside_tree():
		return
	if aggro_against_factions.keys().filter(func (fac): return aggro_against_factions[fac]).is_empty():
		return
	update_aggro_target()


func update_aggro_target() -> void:
	aggro_target = Visibility.get_nearest_aggroed_entity(self)
	print("aggro target updating!", aggro_target)
	if aggro_target == null:
		# If there are no targets visible, reset aggro
		for fac in aggro_against_factions.keys():
			aggro_against_factions[fac] = false
