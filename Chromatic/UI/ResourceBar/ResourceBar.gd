extends Control


#Methods
func set_food(food: int):
	get_node("HBoxContainer/Food/Label").value = food
