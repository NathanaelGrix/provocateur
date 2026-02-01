class_name Bullet
extends Node2D

var target_position:Vector2

func _physics_process(delta: float) -> void:
	position += transform.get_rotation() * position.move_toward(target_position,1) * delta
