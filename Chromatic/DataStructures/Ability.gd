extends Node
class_name Ability

#Fields
var type: int
var data: Dictionary
var icon: Texture
var cast_time: int
var food_cost: int
var gold_cost: int


#Constructors
func _init(_type: int, _data: Dictionary, _icon: Texture, _cast_time = 0, _food_cost = 0, _gold_cost = 0) -> void:
	type = _type
	data = _data
	icon = _icon
	cast_time = _cast_time
	food_cost = _food_cost
	gold_cost = _gold_cost
