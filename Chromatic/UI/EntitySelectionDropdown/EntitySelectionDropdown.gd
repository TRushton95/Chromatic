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


func _on_ResourceNodeOption_pressed() -> void:
	visible = false
	emit_signal("option_selected", 2)


#Event Handlers
func _on_Map_multiple_entities_selected(player_entity: PlayerEntity, resource_node: ResourceNode) -> void:
	_set_options(player_entity, resource_node)
	_refresh_control()
	rect_global_position = get_viewport().get_mouse_position()
	visible = true


#Methods
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var event_local = make_input_local(event)
		var bounds = Rect2(Vector2(0, 0), rect_size)
		
		if !bounds.has_point(event_local.position):
			visible = false


func _set_options(player_entity: PlayerEntity, resource_node: ResourceNode) -> void:
	_set_option(player_entity, unit_option)
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
