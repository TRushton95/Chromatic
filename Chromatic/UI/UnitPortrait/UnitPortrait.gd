extends Control

#Constants
const action_point_string = "Action Points: %s/%s"

#Fields
onready var icon_node = get_node("Panel/HBoxContainer/Border/Icon")
onready var name_node = get_node("Panel/HBoxContainer/VBoxContainer/Name")
onready var action_points_node = get_node("Panel/HBoxContainer/VBoxContainer/ActionPoints")


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


func _on_Map_action_points_updated(current_action_points: int, max_action_points: int) -> void:
	action_points_node.text = action_point_string % [current_action_points, max_action_points]


#Methods
func set_unit(unit: Unit) -> void:
	icon_node.texture = unit.get_node("Sprite").texture
	name_node.text = unit.name
	action_points_node.text = action_point_string % [unit.current_action_points, unit.max_action_points]
