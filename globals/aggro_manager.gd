extends Node

## Faction -> Entity ID -> true (if false, remove from mapping)
var aggro_mapping: Dictionary[Entity.Faction, Dictionary] = {}


func _ready() -> void:
	SignalBus.damage_inflicted.connect(_on_damage_inflicted)
	for fac in Entity.Faction.values():
		aggro_mapping[fac] = {}


func _on_damage_inflicted(attacker: Entity, victim: Entity) -> void:
	var visible_others = Visibility.get_all_entities_visible_to(victim)
	var victim_allies = visible_others.filter(func (other): return other.faction == victim.faction)
	for ally: Entity in victim_allies:
		if aggro_mapping[attacker.faction].has(ally.entity_id):
			continue
		ally.aggro_against_factions[attacker.faction] = true
		aggro_mapping[attacker.faction][ally.entity_id] = true
	if victim.is_inside_tree():
		victim.aggro_against_factions[attacker.faction] = true
		aggro_mapping[attacker.faction][victim.entity_id] = true
