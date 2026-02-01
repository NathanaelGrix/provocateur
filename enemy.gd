extends CharacterBody2D
@export var enemy_details: EnemyDetails
@export var navigation_region: NavigationRegion2D
const SPEED: float = 50000
var next_position: Vector2

func _ready() -> void:
	await get_tree().process_frame
	next_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),1, false)
	
func _process(delta: float) -> void:
	if is_equal_approx(next_position.x, position.x) and is_equal_approx(next_position.y, position.y):
		return
	velocity = (next_position-position).normalized() * SPEED * delta
	move_and_slide()

func _on_timer_timeout() -> void:
	next_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),1,false)
	
#Not sure how to set it up to play proper animations - Sam
func set_animation():
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.animation("walk")
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.animation("idle")
		$AnimatedSprite2D.play()
