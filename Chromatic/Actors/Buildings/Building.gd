extends Entity
class_name Building

#Fields
onready var construction_timer = get_node("ConstructionTimer")

export var max_health = 1
export var construction_requires_worker = true
export var build_time = 0
var build_time_remaining: int setget build_time_remaining_set
var under_construction: bool setget under_construction_set
var current_health setget current_health_set
var team = -1 setget team_set


#Setget
func build_time_remaining_set(value: int) -> void:
	build_time_remaining = value
	construction_timer.set_turns_remaining(build_time_remaining)


func under_construction_set(value: bool) -> void:
	under_construction = value
	
	if under_construction:
		show_construction_timer()
	else:
		hide_construction_timer()


#Methods
func _ready() -> void:
	current_health = max_health
	_init_health_bar(max_health, current_health)
	
	under_construction = true
	build_time_remaining_set(build_time)
	
func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT):
		current_health_set(current_health - 2)
	elif Input.is_key_pressed(KEY_RIGHT):
		current_health_set(current_health + 2)

func show_construction_timer() -> void:
	construction_timer.visible = true


func hide_construction_timer() -> void:
	construction_timer.visible = false


func current_health_set(health: int) -> void:
	current_health = health
	
	if current_health < 0:
		current_health = 0
	elif current_health > max_health:
		current_health = max_health
		
	get_node("BuildingHealthBar").set_value(current_health)


func team_set(team_number: int) -> void:
	team = team_number
	var team_color = Lookups.TEAM_COLORS[team]
	get_node("BuildingHealthBar").set_color(team_color)


func _init_health_bar(max_value: int, current_value: int):
	get_node("BuildingHealthBar").set_max_value(max_value)
	get_node("BuildingHealthBar").set_value(current_value)

