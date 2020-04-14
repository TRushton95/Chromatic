extends Control


func set_turns_remaining(turns: int):
	get_node("HBoxContainer/Label").text = str(turns)
