extends Node

#Fields
onready var unit_portrait = get_node("UI/UnitPortrait")
onready var ability_button = get_node("UI/AbilityButton")


#Event Handlers
func _on_Map_unit_selected(unit) -> void:
	if !unit:
		print_debug("Unit selected: No unit!")
		return
	
	unit_portrait.set_unit(unit)
	unit_portrait.visible = true
	
	if "ability" in unit && unit.ability != null:
		ability_button.set_ability(unit.ability)
		ability_button.visible = true
	else:
		ability_button.visible = false


func _on_Map_unit_deselected() -> void:
	unit_portrait.visible = false
	ability_button.visible = false


func _on_EndTurnButton_pressed() -> void:
	pass # Replace with function body.
