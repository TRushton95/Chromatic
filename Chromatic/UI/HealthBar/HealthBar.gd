extends Control


#Methods
func set_value(value: int) -> void:
	get_node("TextureProgress").value = value


func set_color(color: Color) -> void:
	get_node("TextureProgress").modulate = color
