extends Control


#Event Handlers
func _on_Map_new_player_turn(player: Player) -> void:
	set_food(player.food)



#Methods
func set_food(food: int):
	get_node("HBoxContainer/Food/Label").text = str(food)
