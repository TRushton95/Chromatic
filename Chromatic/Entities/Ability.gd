extends Node
class_name Ability

#Fields
var type: int
var data: Dictionary
var icon: Texture


#Constructors
func _init(_type: int, _data: Dictionary, _icon: Texture) -> void:
	type = _type
	data = _data
	icon = _icon
