extends Label

#Event handlers
func _on_Map_new_player_turn(player_turn: int) -> void:
	text = "Player " + str(player_turn)
