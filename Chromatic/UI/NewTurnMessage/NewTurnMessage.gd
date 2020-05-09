extends Control


#Methods
func _on_Map_new_player_turn(player: Player) -> void:
	get_node("ColorRect/Label").text = "Player " + str(player.team)
	get_node("AnimationPlayer").play("DisplayMessage")
