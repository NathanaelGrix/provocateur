class_name HealthComponent extends Node2D


signal health_depleted


@export var max_health: int = 100


var current_health: int
var health_bar_ui: ProgressBar


func _ready() -> void:
	initialize_health_bar()
	current_health = max_health
	set_up_remote_transform.call_deferred()


func initialize_health_bar() -> void:
	health_bar_ui = ProgressBar.new()
	health_bar_ui.show_percentage = false
	health_bar_ui.size = Vector2(180, 30)
	health_bar_ui.position = Vector2(-90, -160)
	health_bar_ui.max_value = max_health
	health_bar_ui.step = 1
	health_bar_ui.value = max_health
	var bg_stylebox = StyleBoxFlat.new()
	bg_stylebox.bg_color = Color(0, 0, 0)
	health_bar_ui.add_theme_stylebox_override("background", bg_stylebox)
	var fill_stylebox = StyleBoxFlat.new()
	fill_stylebox.bg_color = Color(0.0, 0.722, 0.0, 1.0)
	health_bar_ui.add_theme_stylebox_override("fill", fill_stylebox)
	add_child(health_bar_ui)


## This function modifies this component to ignore the parent entity's rotation
func set_up_remote_transform() -> void:
	top_level = true
	var remote_transform = RemoteTransform2D.new()
	remote_transform.update_rotation = false
	get_parent().add_child(remote_transform)
	remote_transform.remote_path = remote_transform.get_path_to(self)

func take_damage(damage: int) -> void:
	current_health = max(0, current_health - damage)
	health_bar_ui.value = current_health
	if current_health >= 0:
		health_depleted.emit()

func heal(heal_amount: int) -> void:
	current_health = min(max_health, current_health + heal_amount)
	health_bar_ui.value = current_health
