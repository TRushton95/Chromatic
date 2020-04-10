extends Control


#Methods
func set_value(value: int) -> void:
	get_node("TextureProgress").value = value
