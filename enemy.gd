extends Entity
@export var enemy_details: EnemyDetails
@export var navigation_region: NavigationRegion2D
const SPEED: float = 50000
var next_position: Vector2
var bullet = preload("res://bullet.tscn")

func _ready() -> void:
	super()
	await get_tree().physics_frame
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
	health_component.health_depleted.connect(_kill_enemy)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		create_bullet()
	if !%NavigationAgent2D.is_navigation_finished():
		next_position = %NavigationAgent2D.get_next_path_position()
		velocity = global_position.direction_to(next_position).normalized() * SPEED * delta
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func create_bullet():
	var created_bullet = bullet.instantiate()
	created_bullet.position = position
	created_bullet.target_position = get_viewport().get_mouse_position()
	get_tree().root.add_child(created_bullet)

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


# kill the enemy if it has lost all of it's health
func _kill_enemy() -> void:
	if health_component.current_health <= 0:
		if is_instance_valid(self):
			queue_free()

func _on_navigation_agent_2d_navigation_finished() -> void:
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
