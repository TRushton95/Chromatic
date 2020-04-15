extends Entity
class_name PlayerEntity

#Fields
export var max_health = 1
export var melee_attack_damage = 0
export var ranged_attack_damage = 0
export var attack_range = 0
export var can_attack = false
var current_health setget current_health_set
var team = -1 setget team_set
var abilities: Array


#Methods
func _ready() -> void:
	current_health = max_health
	_init_health_bar(max_health, current_health)


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT):
		.current_health_set(current_health - 2)
	elif Input.is_key_pressed(KEY_RIGHT):
		.current_health_set(current_health + 2)


func current_health_set(health: int) -> void:
	current_health = health
	
	if current_health < 0:
		current_health = 0
	elif current_health > max_health:
		current_health = max_health
		
	get_node("HealthBar").set_value(current_health)


func team_set(team_number: int) -> void:
	team = team_number
	var team_color = Lookups.TEAM_COLORS[team]
	get_node("HealthBar").set_color(team_color)


func show_health_bar() -> void:
	get_node("HealthBar").visible = true


func hide_health_bar() -> void:
	get_node("HealthBar").visible = false


func _init_health_bar(max_value: int, current_value: int):
	get_node("HealthBar").set_max_value(max_value)
	get_node("HealthBar").set_value(current_value)
