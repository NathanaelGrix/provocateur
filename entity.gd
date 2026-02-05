class_name Entity extends CharacterBody2D

@export var room_id: String = ""

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
var aggro_timer: Timer

var was_in_combat := false

func _ready() -> void:
	entity_id = IdGenerator.generate_entity_id()
	for fac in Faction.values():
		aggro_against_factions[fac] = false
	assert(visibility_component != null, "All entities must have a visibility component! Make sure to assign it to the \"visibility_component\" variable")
	assert(visibility_component != null, "All entities must have a health component! Make sure to assign it to the \"health_component\" variable")
	assert(faction != Faction.NOT_SET, "You must set a faction alliance for all entities!")
	visibility_component.assign_parent_entity(self)
	if faction != Faction.PLAYER:
		aggro_timer = Timer.new()
		aggro_timer.wait_time = 7
		add_child(aggro_timer)
		aggro_timer.start()
		aggro_timer.timeout.connect(_on_aggro_timeout)


func _physics_process(_delta: float) -> void:
	if aggro_target != null and aggro_target.state == Enemy.State.DEAD:
		update_aggro_target()
		return
	if aggro_target != null and aggro_target.is_inside_tree():
		return
	if aggro_against_factions.keys().filter(func (fac): return aggro_against_factions[fac]).is_empty():
		return
	update_aggro_target()


func is_aggro_against_any_faction() -> bool:
	for fac in aggro_against_factions.keys():
		if aggro_against_factions[fac]:
			return true
	return false


func update_aggro_target() -> void:
	if not is_aggro_against_any_faction():
		exit_combat()
		return
		
	aggro_target = Visibility.get_nearest_aggroed_entity(self)
	
	if aggro_target == null:
		exit_combat()
		# If there are no targets visible, reset aggro
		#for fac in aggro_against_factions.keys():
			#aggro_against_factions[fac] = false
			
	if aggro_target and aggro_target.room_id != room_id:
		exit_combat()
		return


func _on_aggro_timeout() -> void:
	update_aggro_target()


func exit_combat():
	if not was_in_combat:
		return
		
	was_in_combat = false
	aggro_target = null

	for fac in aggro_against_factions.keys():
		aggro_against_factions[fac] = false

	if aggro_timer:
		aggro_timer.stop()

	SignalBus.entity_exited_combat.emit(self)
	
