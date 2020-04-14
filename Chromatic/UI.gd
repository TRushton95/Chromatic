extends CanvasLayer

#Fields
onready var entity_selection_dropdown_scene  = preload("res://UI/EntitySelectionDropdown/EntitySelectionDropdown.tscn")


#Event Handlers
func _on_Map_multiple_entities_selected(entity_options: Array) -> void:
	set_entity_selection_dropdown(entity_options)


#Methods
func set_entity_selection_dropdown(entity_options: Array) -> void:
	if has_node("EntitySelectionDropdown"):
		var prev_selection_dropdown = get_node("EntitySelectionDropdown")
		remove_child(prev_selection_dropdown)
	
	var entity_selection_dropdown = entity_selection_dropdown_scene.instance()
	add_child(entity_selection_dropdown)
	entity_selection_dropdown.set_options(entity_options)
	entity_selection_dropdown.name = "EntitySelectionDropdown"
	entity_selection_dropdown.rect_global_position = get_viewport().get_mouse_position()
