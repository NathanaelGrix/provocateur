class_name Bullet
extends Node2D

var target_position: Vector2
var parentEntity: Entity = null
var direction_fired: Vector2 = Vector2.ZERO


func _ready() -> void:
	$HitArea2D.hit_something.connect(_on_hit_something)
	look_at(target_position)
	get_direction_fired()


func get_direction_fired() -> Vector2:
	direction_fired = (target_position - global_position).normalized()
	return direction_fired


func _physics_process(delta: float) -> void:
	position += direction_fired * delta * 2000


func _on_hit_something() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
