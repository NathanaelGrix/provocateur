class_name HitArea2D extends Area2D

signal hit_somone

@export var damage := 50

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurt_area: HurtArea2D) -> void:
	if owner.parentEntity and hurt_area.owner is Entity:
		hurt_area.owner.health_component.take_damage(damage)
		SignalBus.damage_inflicted.emit(owner.parentEntity, hurt_area.owner)
		hit_somone.emit()
