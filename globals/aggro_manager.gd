extends Node

## Faction -> Entity ID -> true (if false, remove from mapping)
var aggro_mapping: Dictionary[Entity.Faction, Dictionary] = {}
var combat_active := false

func _ready() -> void:
	SignalBus.damage_inflicted.connect(_on_damage_inflicted)
	SignalBus.enemy_exited_combat.connect(_on_enemy_exited_combat)
	
	for fac in Entity.Faction.values():
		aggro_mapping[fac] = {}


func _on_damage_inflicted(attacker: Entity, victim: Entity) -> void:
	if not combat_active:
		combat_active = true
		if GameState.current_state != GameState.State.FIGHT:
			GameState.set_state(GameState.State.FIGHT)
		

	# Prevent friendly fire from turning factions against each other lol
	if attacker.faction == victim.faction:
		return
	# Don't update aggro for the player
	if victim.faction == Entity.Faction.PLAYER:
		return
		
	var visible_others = Visibility.get_all_entities_visible_to(victim)
	var victim_allies = visible_others.filter(func (other): return other.faction == victim.faction)
	
	for ally: Entity in victim_allies:
		if aggro_mapping[attacker.faction].has(ally.entity_id):
			continue
		ally.aggro_against_factions[attacker.faction] = true
		ally.was_in_combat = true
		aggro_mapping[attacker.faction][ally.entity_id] = true
		
	if victim.is_inside_tree():
		victim.aggro_against_factions[attacker.faction] = true
		victim.was_in_combat = true
		aggro_mapping[attacker.faction][victim.entity_id] = true


func _on_enemy_exited_combat(enemy: Enemy):
	if not enemy.was_in_combat:
		return
	
	for faction in aggro_mapping.keys():
		aggro_mapping[faction].erase(enemy.entity_id)
		
	if all_aggro_empty():
		combat_active = false
		GameState.set_state(GameState.State.SNEAKY)
		
func all_aggro_empty() -> bool:
	for faction in aggro_mapping.keys():
		if not aggro_mapping[faction].is_empty():
			return false
	return true
