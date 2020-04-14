extends Actor
class_name Building

#UI Scenes
onready var construction_timer = get_node("ConstructionTimer")

#Fields
export var max_health = 100
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
	under_construction = true
	build_time_remaining_set(build_time)


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
