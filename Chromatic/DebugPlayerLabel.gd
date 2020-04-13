extends Label

#Event handlers
func _on_Map_new_player_turn(player: Player) -> void:
	text = "Player " + str(player.team)
