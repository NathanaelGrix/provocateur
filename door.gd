extends Node2D

var is_open := false
var player_near := false

@onready var blocker = $Blocker/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	close_door()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_near == true and Input.is_action_just_pressed("interact"):
		toggle_door()

func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()
		
func open_door():
	is_open = true
	blocker.disabled = true
	$AnimatedSprite2D.play("door animation")
	
	$AutoCloseDoorTimer.stop()
	$AutoCloseDoorTimer.start()
	
func close_door():
	is_open = false
	
	blocker.disabled = false
	$AnimatedSprite2D.play_backwards("door animation")
	

func _on_player_near_body_entered(body):
	if body.is_in_group("player"):
		player_near = true


func _on_player_near_body_exited(body):
	if body.is_in_group("player"):
		player_near = false



func _on_auto_close_door_timer_timeout():
	if is_open:
		close_door()
