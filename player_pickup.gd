extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area.owner is Enemy:
		if area.owner.state == Enemy.State.DEAD:
			SignalBus.player_changed_faction.emit(area.owner.faction)
			area.owner.queue_free()
