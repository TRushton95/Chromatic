extends Control


#Event Handlers
func _on_Map_new_player_turn(player: Player) -> void:
	get_node("HBoxContainer/ColorRect").color = player.color
	get_node("HBoxContainer/Label").text = "PLAYER " + str(player.team)
