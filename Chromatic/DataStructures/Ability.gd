extends Node
class_name Ability

#Fields
var type: int
var data: Dictionary
var icon: Texture
var production_time: int
var food_cost: int
var gold_cost: int


#Constructors
func _init(_type: int, _data: Dictionary, _icon: Texture, _production_time = 0, _food_cost = 0, _gold_cost = 0) -> void:
	type = _type
	data = _data
	icon = _icon
	production_time = _production_time
	food_cost = _food_cost
	gold_cost = _gold_cost
