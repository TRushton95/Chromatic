extends Control

#Constants
const MAX_ABILITY_COUNT = 4

#Signals
signal ability_pressed


#Event Handlers
func _on_Map_entity_selected(entity: Entity) -> void:
	if !entity || entity is ResourceNode:
		print("Failed to display ability bar")
		return
	
	if entity.abilities:
		visible = true
		set_abilities(entity.abilities)
	else:
		visible = false


func _on_Map_entity_deselected() -> void:
	visible = false


func _on_AbilityButton1_pressed() -> void:
	emit_signal("ability_pressed", 0)


func _on_AbilityButton2_pressed() -> void:
	emit_signal("ability_pressed", 1)


func _on_AbilityButton3_pressed() -> void:
	emit_signal("ability_pressed", 2)


func _on_AbilityButton4_pressed() -> void:
	emit_signal("ability_pressed", 3)


#Methods
func set_abilities(abilities) -> void:
	for i in range(0, MAX_ABILITY_COUNT):
		var ability_button = get_node("Panel/HBoxContainer/AbilityButton" + str(i + 1))
		
		if i < abilities.size():
			ability_button.set_ability(abilities[i])
			ability_button.visible = true
		else:
			ability_button.visible = false
