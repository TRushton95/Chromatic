extends Node2D
class_name Building

#Fields
export var build_time = 0
var build_time_remaining setget build_time_remaining_set
var under_construction = true
var coordinates = Vector2(-1, -1)
var team = -1


#Methods
func _ready() -> void:
	build_time_remaining_set(build_time)


func build_time_remaining_set(time_remaining: int) -> void:
	build_time_remaining = time_remaining
	
	var construction_timer = get_node("ConstructionTimer")
	if build_time_remaining == 0:
		construction_timer.visible = false
	else:
		construction_timer.set_turns_remaining(build_time_remaining)


func show_construction_timer() -> void:
	get_node("ConstuctionTimer").visible = true


func hide_construction_timer() -> void:
	get_node("ConstuctionTimer").visible = false
