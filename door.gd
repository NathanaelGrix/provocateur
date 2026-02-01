extends Node2D

@export var is_locked := true
@export var starts_unlocked := false

var is_open := false
var player_near := false
var door_has_been_used := false

@onready var blocker := get_node_or_null("Blocker/CollisionShape2D")
@onready var next_door_ind = $NextDoorIndicator
@onready var auto_close_timer = $AutoCloseDoorTimer


func _ready():
	if next_door_ind:
		next_door_ind.visible = false
	
	close_door()
	
	if starts_unlocked:
		unlock()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_near == true and Input.is_action_just_pressed("interact"):
		if not is_locked:
			toggle_door()

func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()
		
func open_door():
	is_open = true
	if blocker:
		blocker.disabled = true
	$AnimatedSprite2D.play("door animation")
	$AudioStreamPlayer.play()
	
	auto_close_timer.stop()
	auto_close_timer.start()
	
func close_door():
	is_open = false
	if blocker:
		blocker.disabled = false
	$AnimatedSprite2D.play_backwards("door animation")
	$AudioStreamPlayer.play()
	
func unlock(show_indicator := true):
	is_locked = false
	if show_indicator:
		show_next_door_ind()
	
func lock():
	is_locked = true
	hide_next_door_ind()
	
func show_next_door_ind():
	if next_door_ind and not door_has_been_used:
		next_door_ind.visible = true
	
func hide_next_door_ind():
	if next_door_ind:
		next_door_ind.visible = false
	

func _on_player_near_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		
		hide_next_door_ind()

func _on_player_near_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		
		if is_open and not door_has_been_used:
			door_has_been_used = true
			hide_next_door_ind()


func _on_auto_close_door_timer_timeout():
	if is_open:
		close_door()
