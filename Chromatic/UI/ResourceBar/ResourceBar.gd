extends Control


#Event Handlers
func _on_Map_new_player_turn(player: Player) -> void:
	set_food(player.food)
	set_gold(player.gold)


#Methods
func set_food(food: int):
	get_node("HBoxContainer/Food/Label").text = str(food)


func set_gold(gold: int):
	get_node("HBoxContainer/Gold/Label").text = str(gold)


func _on_Map_resource_updated(resource_type: int, value: int) -> void:
	match resource_type:
		Enums.RESOURCE_TYPE.FOOD:
			set_food(value)
		Enums.RESOURCE_TYPE.GOLD:
			set_gold(value)
