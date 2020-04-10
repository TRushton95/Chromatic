extends Control

#Event Handlers

#Methods
func set_icon(texture_path: String) -> void:
	get_node("Border/Icon").texture = load(texture_path)
