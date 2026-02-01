extends Entity
@export var enemy_details: EnemyDetails
@export var navigation_region: NavigationRegion2D
const SPEED: float = 50000
var next_position: Vector2
var bullet = preload("res://bullet.tscn")
var state: State

enum State{
	MOVING,
	DEAD,
	IDLE
}

func _ready() -> void:
	super()
	await get_tree().physics_frame
	change_state(State.MOVING)
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
	health_component.health_depleted.connect(_kill_enemy)
	$AttackCooldownTimer.timeout.connect(_on_attack_off_cooldown)
	
func _physics_process(delta: float) -> void:
	super(delta)
	if state == State.MOVING:
		if !%NavigationAgent2D.is_navigation_finished():
			next_position = %NavigationAgent2D.get_next_path_position()
			velocity = global_position.direction_to(next_position).normalized() * SPEED * delta
		else:
			velocity = Vector2.ZERO
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		


func create_bullet():
	var created_bullet = bullet.instantiate()
	created_bullet.parentEntity = self
	created_bullet.position = position
	created_bullet.target_position = aggro_target.global_position
	get_tree().root.add_child(created_bullet)


func _on_attack_off_cooldown() -> void:
	if aggro_target != null:
		create_bullet()
	else:
		$AttackCooldownTimer.stop()


func update_aggro_target() -> void:
	super()
	$AttackCooldownTimer.start(1)


func _on_timer_timeout() -> void:
	next_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),1,false)

func change_state(local_state: State):
	match local_state:
		State.MOVING:
			%AnimatedSprite2D.animation = "walk"
			%AnimatedSprite2D.play()
		State.DEAD:
			%AnimatedSprite2D.animation = "dead"
			%AnimatedSprite2D.play()
			aggro_target = null
			$AttackCooldownTimer.paused = true
			health_component.visible = false
		State.IDLE:
			%AnimatedSprite2D.animation = "idle"
			%AnimatedSprite2D.play()
	state = local_state
	
# kill the enemy if it has lost all of it's health
func _kill_enemy() -> void:
	if health_component.current_health <= 0:
		if is_instance_valid(self):
			change_state(State.DEAD)
			

func _on_navigation_agent_2d_navigation_finished() -> void:
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
