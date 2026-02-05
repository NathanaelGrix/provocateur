extends Node


signal damage_inflicted(attacker: Entity, victim: Entity)
signal enemy_exited_combat(enemy: Enemy)
signal player_changed_faction(new_faction: Entity.Faction)
