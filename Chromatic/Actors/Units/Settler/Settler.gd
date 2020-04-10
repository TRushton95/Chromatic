extends Unit
class_name Settler

#Fields
var ability = preload("res://Entities/Abilities/BuildSettlementAbility.gd").new()

#Signals
signal build_settlement


#Methods
func build_settlement():
	emit_signal("build_settlement", self)
