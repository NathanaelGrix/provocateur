class_name Enemy extends Entity

@export var enemy_details: EnemyDetails
@export var navigation_region: NavigationRegion2D
@export var drop_key_on_death: PackedScene

@export var room_controller: NodePath

const SPEED: float = 20000
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
	add_to_group("enemies")
	print("Enemy ready:", name, "room:", room_id)
	await get_tree().physics_frame
	change_state(State.MOVING)
	
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
	
	health_component.health_depleted.connect(_kill_enemy)
	$Timer.timeout.connect(_on_timer_timeout)
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
	set_animation()
	move_and_slide()


func create_bullet():
	if enemy_details and enemy_details.gunshot_sound:
		$AudioStreamPlayer2D_Gun.stream = enemy_details.gunshot_sound
		$AudioStreamPlayer2D_Gun.play()
	
	var created_bullet = bullet.instantiate()
	created_bullet.parentEntity = self
	created_bullet.target_position = aggro_target.global_position
	created_bullet.global_position = global_position
	created_bullet.global_position += (200 * created_bullet.get_direction_fired())
	get_tree().root.add_child(created_bullet)


func _on_attack_off_cooldown() -> void:
	if aggro_target != null:
		create_bullet()
	else:
		$AttackCooldownTimer.stop()


func update_aggro_target() -> void:
	if state == State.DEAD:
		return
		
	super()
	
	if aggro_target == null:
		exit_combat()
	else:
		$AttackCooldownTimer.start(1)


func exit_combat():
	aggro_target = null
	$AttackCooldownTimer.stop()
	
	for faction in aggro_against_factions.keys():
		aggro_against_factions[faction] = false
	
	change_state(State.MOVING)
	
	SignalBus.enemy_exited_combat.emit(self)

func _on_timer_timeout() -> void:
	next_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers,false)

func change_state(local_state: State):
	match local_state:
		State.MOVING:
			%AnimatedSprite2D.animation = enemy_details.walk_animation
			%AnimatedSprite2D.play()
		State.DEAD:
			%AnimatedSprite2D.animation = enemy_details.dead_animation
			%AnimatedSprite2D.play()
			aggro_target = null
			$AttackCooldownTimer.paused = true
			health_component.visible = false
		State.IDLE:
			%AnimatedSprite2D.animation = enemy_details.idle_animation
			%AnimatedSprite2D.play()
	state = local_state


#Not sure how to set it up to play proper animations - Sam
func set_animation():
	if enemy_details == null or state == State.DEAD:
		return
	if velocity.length() > 0:
		$AnimatedSprite2D.play(enemy_details.walk_animation)
	else:
		$AnimatedSprite2D.play(enemy_details.idle_animation)


# kill the enemy if it has lost all of it's health
func _kill_enemy() -> void:
	if state == State.DEAD:
		return
		
	if health_component.current_health <= 0:
		if is_instance_valid(self):
			print("Enemy died:", name)
			print("Drop key scene:", drop_key_on_death)
			change_state(State.DEAD)
			
			if drop_key_on_death:
				print("Enemy died. Drop key:", drop_key_on_death)
				var key = drop_key_on_death.instantiate()
				key.global_position = global_position
				key.controller = get_node(room_controller).get_path()
				get_tree().current_scene.add_child(key)
				print("Key spawned at:", global_position)
				
				
				drop_key_on_death = null
			

func _on_navigation_agent_2d_navigation_finished() -> void:
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
