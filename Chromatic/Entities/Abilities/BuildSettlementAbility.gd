extends Node
class_name BuildSettlementAbility

#Fields
var settlement_scene = preload("res://Actors/Buildings/Settlement/Settlement.tscn")

#Signals
signal build_settlement_action


#Methods
func execute(tile):
	emit_signal("build_settlement_action", tile)


func get_texture() -> String:
	return "res://Assets/Buildings/Settlement.png"
