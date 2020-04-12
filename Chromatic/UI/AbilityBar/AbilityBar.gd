extends Control

#Constants
const MAX_ABILITY_COUNT = 4

#Fields
var abilities: Array

#Signals
signal ability_selected


#Event Handlers
func _on_Map_unit_selected(unit: Unit) -> void:
	if unit && unit.abilities:
		visible = true
		set_abilities(unit.abilities)


func _on_Map_unit_deselected() -> void:
	visible = false


func _on_AbilityButton1_pressed() -> void:
	emit_signal("ability_selected", abilities[0].type, abilities[0].data)


func _on_AbilityButton2_ability_selected() -> void:
	emit_signal("ability_selected", abilities[1].type, abilities[1].data)


func _on_AbilityButton3_ability_selected() -> void:
	emit_signal("ability_selected", abilities[2].type, abilities[2].data)


func _on_AbilityButton4_ability_selected() -> void:
	emit_signal("ability_selected", abilities[3].type, abilities[3].data)



#Methods
func set_abilities(new_abilities) -> void:
	abilities = new_abilities
	
	for i in range(0, MAX_ABILITY_COUNT):
		var ability_button = get_node("Panel/HBoxContainer/AbilityButton" + str(i + 1))
		
		if i < abilities.size():
			ability_button.set_ability(abilities[i])
			ability_button.visible = true
		else:
			ability_button.visible = false
