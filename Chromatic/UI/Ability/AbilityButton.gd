extends Control

#Fields
var ability

#Methods
func set_ability(new_ability) -> void:
	ability = new_ability
	get_node("Border/Icon").texture = ability.icon
	
