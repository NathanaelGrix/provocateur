extends Node2D

@onready var darkness := $Darkness
@onready var darkness2 := $Darkness2
@onready var tween := create_tween()

@export var room_id: String
@export var keycard_scene: PackedScene

var explored := false

func  _ready():
	darkness.visible = true
	darkness2.visible = true
	darkness.modulate.a = 1.0
	darkness2.modulate.a = 1.0
	
	await  get_tree().process_frame
	assign_key_to_random_enemy()
	

func _on_area_2d_body_entered(body):
	if body.name == "player":
		reveal()
		
func _on_area_2d_body_exited(body):
	if body.name == "player":
		hide_room()
		
func reveal():
	explored = true
	if tween: tween.kill()
	tween = create_tween()

	tween.tween_property(darkness, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(darkness2, "modulate:a", 0.0, 0.4)

func hide_room():
	if explored:
		tween.kill()
		tween = create_tween()

		tween.tween_property(darkness, "modulate:a", 0.6, 0.4)
		tween.parallel().tween_property(darkness2, "modulate:a", 0.6, 0.4)

	
	
func assign_key_to_random_enemy():
	var all_enemies := get_tree().get_nodes_in_group("enemies")

	var room_enemies: Array[Enemy] = []

	for enemy in all_enemies:
		if enemy.room_id == room_id:
			room_enemies.append(enemy)

	if room_enemies.is_empty():
		return

	var chosen_enemy: Enemy = room_enemies.pick_random()
	chosen_enemy.drop_key_on_death = keycard_scene
	
	print("Key assigned to:", chosen_enemy.name)
