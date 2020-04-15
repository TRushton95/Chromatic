extends Control

#Fields
onready var icon_node = get_node("Panel/HBoxContainer/Border/Icon")
onready var name_node = get_node("Panel/HBoxContainer/Name")


#Event Handlers
func _on_Map_entity_selected(entity: Entity) -> void:
	if !entity:
		print_debug("Entity selected: no entity")
		return
	
	if !entity is Unit:
		visible = false
		return
	
	set_unit(entity)
	visible = true

func _on_Map_entity_deselected() -> void:
	visible = false


#Methods
func set_unit(unit: Unit) -> void:
	icon_node.texture = unit.get_node("Sprite").texture
	name_node.text = unit.name
