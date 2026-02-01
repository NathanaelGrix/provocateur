extends Entity
const SPEED:float = 50000

@export var dash_speed := 2000.0

var is_dashing := false
var can_dash := true
var last_direction := Vector2.RIGHT
var dash_direction := Vector2.ZERO


enum PlayerState {IDLE, MOVE, DASH, COWBOY, ALIEN}

@export var sfx_player_footstep : AudioStream
@export var sfx_player_dash: AudioStream

var foot_step_frames : Array = [4]

var state: PlayerState = PlayerState.IDLE

func change_state(new_state: PlayerState) -> void:
	#print("new_state: ", new_state)
	if state == new_state:
		return
		
	state = new_state

	match state:
		PlayerState.IDLE:
			$AnimatedSprite2D.play("idle")
			
		PlayerState.MOVE:
			$AnimatedSprite2D.play("move")
			
		PlayerState.DASH:
			$AnimatedSprite2D.play("dash")
			
		PlayerState.COWBOY:
			$AnimatedSprite2D.play("cowboyDisguise")
			
		PlayerState.ALIEN:
			$AnimatedSprite2D.play("alienDisguise")

@export var attack_cooldown := 0.5

var is_attacking := false
var attack_ready := true

func _ready() -> void:
	super()
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	$DashTimer.timeout.connect(_on_dash_timer_timeout)
	$DashCooldownTimer.timeout.connect(_on_dash_cooldown_timer_timeout)
	$weapon/AnimatedSprite2D.animation_finished.connect(_on_attack_finished)
	
func _process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("tempTurnAlien"):
		faction = Faction.ALIEN	
	if Input.is_action_just_pressed("tempTurnCowboy"):
		faction = Faction.COWBOY
	if Input.is_action_just_pressed("tempTurnPlayer"):
		faction = Faction.PLAYER
	
	if Input.is_action_just_pressed("dash") and can_dash:
		$PlayerDashSFX.stream = sfx_player_dash
		$PlayerDashSFX.play()
		start_dash()
		
	if !is_dashing and direction != Vector2.ZERO:
		last_direction = direction.normalized()
		
		#if direction == Vector2.ZERO:
			#change_state(PlayerState.IDLE)
			#handle_idle()
		#else:
			#change_state(PlayerState.MOVE)
			#handle_move(direction, delta)

		
	if Input.is_action_just_pressed("attack"):
		start_attack()
		
	match state:
		PlayerState.IDLE:
			handle_idle()
		PlayerState.MOVE:
			handle_move(direction, delta)
			
	move_and_slide()


func _physics_process(delta: float) -> void:
	super(delta)
	var direction = Input.get_vector("left", "right", "up", "down")
	
	match faction:
		Faction.PLAYER:
			if is_dashing:
				change_state(PlayerState.DASH)
				velocity = last_direction * dash_speed
			else:
				if direction == Vector2.ZERO:
					change_state(PlayerState.IDLE)
					handle_idle()
				else:
					change_state(PlayerState.MOVE)
					handle_move(direction, delta)
		Faction.COWBOY:
			change_state(PlayerState.COWBOY)
			if is_dashing:
				velocity = last_direction * dash_speed
			else:
				if direction == Vector2.ZERO:
					handle_idle()
				else:
					handle_move(direction, delta)
		Faction.ALIEN:
			change_state(PlayerState.ALIEN)
			if is_dashing:
				velocity = last_direction * dash_speed
			else:
				if direction == Vector2.ZERO:
					handle_idle()
				else:
					handle_move(direction, delta)

	move_and_slide()

func start_dash():
	is_dashing = true
	can_dash = false
	
	dash_direction = last_direction
	
	if faction == Faction.PLAYER:
		change_state(PlayerState.DASH)
	$DashTimer.start()


func handle_idle() -> void:
	velocity = velocity.lerp(Vector2.ZERO, 0.2)
	
func handle_move(direction: Vector2, delta: float) -> void:
	velocity = direction.normalized() * SPEED * delta


func start_attack():
	if attack_ready:
		is_attacking = true
		attack_ready = false
		print("attacking")
		$weapon.rotation = global_position.angle_to_point(get_global_mouse_position())
		$weapon/AnimatedSprite2D.visible = true
		$weapon/AnimatedSprite2D/HitArea2D/HitBox.disabled = false
		$weapon/AnimatedSprite2D.play("attack")
		$AttackRechargeTimer.start()
	

func _on_attack_recharge_timer_timeout():
	attack_ready = true


func _on_attack_finished():
	print("Done Attacking")
	is_attacking = false
	$weapon/AnimatedSprite2D.visible = false
	$weapon/AnimatedSprite2D/HitArea2D/HitBox.disabled = true
	if faction == Faction.PLAYER:
		if velocity != Vector2.ZERO:
			change_state(PlayerState.MOVE)
			#$AnimatedSprite2D.play("move")
		else:
			change_state(PlayerState.IDLE)
			#$AnimatedSprite2D.play("idle")
	#$AnimatedSprite2D.play()



func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation in ["idle", "attack", "dash"]:
		return

	if $AnimatedSprite2D.frame in foot_step_frames:
		$PlayerFootstepSFX.stream = sfx_player_footstep
		$PlayerFootstepSFX.play()


func _on_dash_timer_timeout():
	is_dashing = false
	dash_direction = Vector2.ZERO
	$DashCooldownTimer.start()
	

func _on_dash_cooldown_timer_timeout():
	can_dash = true
