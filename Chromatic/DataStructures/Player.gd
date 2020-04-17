extends Node
class_name Player

var team : int
var color: Color
var food : int setget food_set
var gold: int setget gold_set

signal resource_updated

#Constructors
func _init(_team: int, _color: Color, _food: int, _gold: int) -> void:
	team = _team
	color = _color
	food = _food
	gold = _gold


#Setgetters
func food_set(value: int) -> void:
	food = value
	emit_signal("resource_updated", Enums.RESOURCE_TYPE.FOOD, food)


func gold_set(value: int) -> void:
	gold = value
	emit_signal("resource_updated", Enums.RESOURCE_TYPE.GOLD, gold)
