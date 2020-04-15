extends PanelContainer

#Fields
onready var unit_option = get_node("VBoxContainer/UnitOption")
onready var building_option = get_node("VBoxContainer/BuildingOption")
onready var resource_node_option = get_node("VBoxContainer/ResourceNodeOption")

#Signals
signal option_selected


#Event Handlers
func _on_UnitOption_pressed() -> void:
	visible = false
	emit_signal("option_selected", 0)


func _on_BuildingOption_pressed() -> void:
	visible = false
	emit_signal("option_selected", 1)


func _on_ResourceNodeOption_pressed() -> void:
	visible = false
	emit_signal("option_selected", 2)


#Event Handlers
func _on_Map_multiple_entities_selected(unit: Unit, building: Building, resource_node: ResourceNode) -> void:
	_set_options(unit, building, resource_node)
	_refresh_control()
	rect_global_position = get_viewport().get_mouse_position()
	visible = true


#Methods
func _set_options(unit: Unit, building: Building, resource_node: ResourceNode) -> void:
	_set_option(unit, unit_option)
	_set_option(building, building_option)
	_set_option(resource_node, resource_node_option)


func _set_option(entity: Entity, option: Node) -> void:
	if entity:
		option.text = entity.name
		option.visible = true
	else:
		option.visible = false


#Force control to recalculate height
func _refresh_control() -> void:
	set_size(get_minimum_size())