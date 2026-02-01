extends Area2D

@export var controller: NodePath

func _ready() -> void:
	$AnimatedSprite2D.play()
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		get_node(controller).unlock_next_door()
		$AudioStreamPlayer.play()
		$AnimatedSprite2D.hide()
		$CollisionShape2D.queue_free()


func _on_audio_stream_player_finished():
	queue_free()
