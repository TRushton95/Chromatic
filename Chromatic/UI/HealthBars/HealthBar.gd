extends Control


#Methods
func set_max_value(value: int) -> void:
	get_node("TextureProgress").max_value = value


func set_value(value: int) -> void:
	get_node("TextureProgress").value = value


func set_color(color: Color) -> void:
	get_node("TextureProgress").modulate = color
