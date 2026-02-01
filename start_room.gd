extends Node2D

@onready var darkness := $Darkness
@onready var tween := create_tween()

var explored := false

func  _ready():
	darkness.visible = true
	darkness.modulate.a = 1.0
	

func _on_area_2d_body_entered(body):
	if body.name == "player":
		reveal()

func _on_area_2d_body_exited(body):
	if body.name == "player":
		hide_room()
		
func reveal():
	explored = true
	tween.kill()
	tween = create_tween()
	tween.tween_property(darkness, "modulate:a", 0.0, 0.4)

func hide_room():
	if explored:
		tween.kill()
		tween = create_tween()
		tween.tween_property(darkness, "modulate:a", 0.6, 0.4)
