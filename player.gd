extends Entity
const SPEED:float = 50000

enum PlayerState {IDLE, MOVE}

@export var sfx_player_footstep : AudioStream
@export var sfx_player_attack : AudioStream

var foot_step_frames : Array = [2]

var state: PlayerState = PlayerState.IDLE

func change_state(new_state: PlayerState) -> void:
	#print("new_state: ", new_state)
	if state == new_state:
		return
		
	state = new_state
	
	if !is_attacking:
		match state:
			PlayerState.IDLE:
				$AnimatedSprite2D.play("idle")
				
			PlayerState.MOVE:
				$AnimatedSprite2D.play("move")

@export var attack_cooldown := 0.5

var is_attacking := false
var attack_ready := true

func _ready() -> void:
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	pass
	
func _process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction == Vector2.ZERO:
		change_state(PlayerState.IDLE)
	else:
		change_state(PlayerState.MOVE)
		
	if Input.is_action_just_pressed("attack"):
		start_attack()
		
	match state:
		PlayerState.IDLE:
			handle_idle()
		PlayerState.MOVE:
			handle_move(direction, delta)
			
	move_and_slide()
	

func handle_idle() -> void:
	velocity = velocity.lerp(Vector2.ZERO, 0.2)
	
func handle_move(direction: Vector2, delta: float) -> void:
	velocity = direction.normalized() * SPEED * delta
	
func handle_attack() -> void:
	pass


func start_attack():
	if attack_ready:
		is_attacking = true
		attack_ready = false
		print("attacking")
		$weapon/AnimatedSprite2D.visible = true
		$weapon/AnimatedSprite2D/HitArea2D/HitBox.disabled = false
		load_sfx(sfx_player_attack)
		$player_sfxs.play()
		$AnimatedSprite2D.play("attack")
		$AttackRechargeTimer.start()
	

func _on_attack_recharge_timer_timeout():
	attack_ready = true


func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "attack":
		print("Done Attacking")
		is_attacking = false
		$weapon/AnimatedSprite2D.visible = false
		$weapon/AnimatedSprite2D/HitArea2D/HitBox.disabled = true
		if velocity != Vector2.ZERO:
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.play()

func load_sfx(sfx_to_load):
	if $player_sfxs.stream != sfx_to_load:
		$player_sfxs.stop()
		$player_sfxs.stream = sfx_to_load


func _on_animated_sprite_2d_frame_changed():
	if $AnimatedSprite2D.animation == "idle": return
	if $AnimatedSprite2D.animation == "attack": return
	load_sfx(sfx_player_footstep)
	if $AnimatedSprite2D.frame in foot_step_frames: $player_sfxs.play()
