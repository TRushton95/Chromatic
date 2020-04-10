extends Node2D
class_name Unit

#Fields
export var max_health = 100
export var attack_damage = 0
var current_health setget current_health_set
var team = -1
var coordinates = Vector2(-1, -1)


#Methods
func _ready() -> void:
	current_health = max_health
	
func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT):
		current_health_set(current_health - 2)
	elif Input.is_key_pressed(KEY_RIGHT):
		current_health_set(current_health + 2)

func current_health_set(health: int) -> void:
	current_health = health
	
	if current_health < 0:
		current_health = 0
	elif current_health > max_health:
		current_health = max_health
		
	get_node("HealthBar").set_value(current_health)


func show_health_bar() -> void:
	get_node("HealthBar").visible = true


func hide_health_bar() -> void:
	get_node("HealthBar").visible = false
