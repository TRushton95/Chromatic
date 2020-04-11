extends Control

#Fields
var ability

#Signals
signal ability_selected


#Methods
func set_ability(new_ability) -> void:
	ability = new_ability
	get_node("Border/Icon").texture = ability.icon
	


func _on_AbilityButton_pressed() -> void:
	emit_signal("ability_selected", ability.type, ability.data)
