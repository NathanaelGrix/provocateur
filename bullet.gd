class_name Bullet
extends Node2D

var target_position: Vector2
var parentEntity: Entity = null
var direction_fired: Vector2


func _ready() -> void:
	$HitArea2D.hit_somone.connect(_on_hit_someone)
	look_at(target_position)
	direction_fired = (target_position - global_position).normalized()
	

func _physics_process(delta: float) -> void:
	position += direction_fired * delta * 2000


func _on_hit_someone() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
