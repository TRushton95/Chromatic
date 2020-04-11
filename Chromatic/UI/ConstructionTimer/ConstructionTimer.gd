extends Control


func set_turns_remaining(turns: int):
	get_node("Label").text = str(turns) + " turns"
