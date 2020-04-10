extends Control

onready var icon_node = get_node("Panel/HBoxContainer/Border/Icon")
onready var name_node = get_node("Panel/HBoxContainer/Name")

func set_unit(unit: Unit) -> void:
	icon_node.texture = unit.get_node("Sprite").texture
	name_node.text = unit.name
