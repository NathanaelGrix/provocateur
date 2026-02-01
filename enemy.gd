extends Entity
@export var enemy_details: EnemyDetails
@export var navigation_region: NavigationRegion2D
const SPEED: float = 50000
var next_position: Vector2

func _ready() -> void:
	super()
	await get_tree().physics_frame
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
	health_component.health_depleted.connect(_kill_enemy)
	
func _physics_process(delta: float) -> void:
	if !%NavigationAgent2D.is_navigation_finished():
		next_position = %NavigationAgent2D.get_next_path_position()
		velocity = global_position.direction_to(next_position).normalized() * SPEED * delta
	else:
		velocity = Vector2.ZERO
	move_and_slide()

# kill the enemy if it has lost all of it's health
func _kill_enemy() -> void:
	if health_component.current_health <= 0:
		if is_instance_valid(self):
			queue_free()

func _on_navigation_agent_2d_navigation_finished() -> void:
	%NavigationAgent2D.target_position = NavigationServer2D.region_get_random_point(navigation_region.get_rid(),%NavigationAgent2D.navigation_layers, false)
