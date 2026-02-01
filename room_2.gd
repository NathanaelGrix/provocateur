extends Node2D

@onready var darkness := $Darkness
@onready var tween := create_tween()

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
	tween.kill()
	tween = create_tween()
	tween.tween_property(darkness, "modulate:a", 0.0, 0.4)

func hide_room():
	tween.kill()
	tween = create_tween()
	tween.tween_property(darkness, "modulate:a", 1.0, 0.4)
