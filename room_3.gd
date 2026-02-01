extends Node2D

@onready var darkness := $Darkness
@onready var darkness2 := $Darkness2
@onready var tween := create_tween()

func  _ready():
	darkness.visible = true
	darkness2.visible = true
	darkness.modulate.a = 1.0
	darkness2.modulate.a = 1.0
	

func _on_area_2d_body_entered(body):
	if body.name == "player":
		reveal()
		
func _on_area_2d_body_exited(body):
	if body.name == "player":
		hide_room()
		
func reveal():
	if tween: tween.kill()
	tween = create_tween()

	tween.tween_property(darkness, "modulate:a", 0.0, 0.4)
	tween.parallel().tween_property(darkness2, "modulate:a", 0.0, 0.4)

func hide_room():
	if tween: tween.kill()
	tween = create_tween()

	tween.tween_property(darkness, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(darkness2, "modulate:a", 1.0, 0.4)
