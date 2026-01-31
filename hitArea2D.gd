class_name HitArea2D extends Area2D

@export var damage := 50

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hurt_area: HurtArea2D) -> void:
	print("I hit him:", owner)
