extends CharacterBody2D
const SPEED:float = 50000

enum PlayerState {IDLE, MOVE, ATTACK}

var state: PlayerState = PlayerState.IDLE

func change_state(new_state: PlayerState) -> void:
	if state == new_state:
		return
		
	state = new_state
	
	match state:
		PlayerState.IDLE:
			velocity = Vector2.ZERO
			$AnimatedSprite2D.play("idle")
			
		PlayerState.MOVE:
			$AnimatedSprite2D.play("move")
			
		PlayerState.ATTACK:
			$AnimatedSprite2D.play("attack")

@export var attack_cooldown := 0.5

var is_attacking := false
var attack_ready := true

func _ready() -> void:
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	pass
	
func _process(delta: float) -> void:
	#var direction: Vector2 = Input.get_vector("left", "right","up","down").normalized()
	
	#if direction == Vector2.ZERO:
		#$AnimatedSprite2D.animation = "idle"
		#velocity = velocity.lerp(Vector2.ZERO,.2)
	#else:
		#$AnimatedSprite2D.animation = "move"
		#velocity = direction * SPEED * delta
		#velocity.x = clamp(velocity.x,-SPEED,SPEED)
		#velocity.y = clamp(velocity.y,-SPEED,SPEED)"
		
	match state:
		PlayerState.IDLE:
			handle_idle(delta)
		PlayerState.MOVE:
			handle_move(delta)
		PlayerState.ATTACK:
			handle_attack(delta)
			
	move_and_slide()
	

func handle_idle(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		change_state(PlayerState.MOVE)

	if Input.is_action_just_pressed("attack") and attack_ready:
		start_attack()
	
func handle_move(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")

	if direction == Vector2.ZERO:
		change_state(PlayerState.IDLE)
		velocity = velocity.lerp(Vector2.ZERO, 0.2)
	else:
		velocity = direction.normalized() * SPEED * delta

	if Input.is_action_just_pressed("attack") and attack_ready:
		start_attack()

func handle_attack(delta: float) -> void:
	pass


func start_attack():
	is_attacking = true
	attack_ready = false
	change_state(PlayerState.ATTACK)
	$AttackRechargeTimer.start()
	

func _on_attack_recharge_timer_timeout():
	attack_ready = true


func _on_animated_sprite_2d_animation_finished():
	if state == PlayerState.ATTACK:
		change_state(PlayerState.IDLE)
