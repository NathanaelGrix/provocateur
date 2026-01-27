extends CharacterBody2D
const SPEED:float = 50000

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right","up","down").normalized()
	if direction == Vector2.ZERO:
		velocity = velocity.lerp(Vector2.ZERO,.2)
	else:
		velocity = direction * SPEED * delta
		velocity.x = clamp(velocity.x,-SPEED,SPEED)
		velocity.y = clamp(velocity.y,-SPEED,SPEED)
	move_and_slide()
