class_name HitArea2D extends Area2D

signal hit_something

@export var damage := 50
@export var ignore_walls = false

var already_hit: Array[Entity] = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if not ignore_walls:
		body_entered.connect(_on_body_entered)
	assert(owner.parentEntity, "Owner must have a parentEntity!")


func is_entity_already_hit(entity: Entity) -> bool:
	if not is_instance_valid(entity) or not entity.is_inside_tree():
		return true
	for prev_entity in already_hit:
		if is_instance_valid(prev_entity) and prev_entity.is_inside_tree() and prev_entity.entity_id == entity.entity_id:
			return true
	return false


func _on_area_entered(hurt_area: Area2D) -> void:
	if not hurt_area is HurtArea2D:
		return
	if hurt_area.owner is Entity and not is_entity_already_hit(hurt_area.owner):
		already_hit.append(hurt_area.owner)
		hurt_area.owner.health_component.take_damage(damage)
		SignalBus.damage_inflicted.emit(owner.parentEntity, hurt_area.owner)
		hit_something.emit()


func _on_body_entered(body: Node2D) -> void:
	if body.owner is Entity:
		return
	hit_something.emit()
