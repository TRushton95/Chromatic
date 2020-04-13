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
