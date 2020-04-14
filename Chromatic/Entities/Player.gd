extends Node
class_name Player

var team : int
var color: Color
var food : int
var gold: int

#Constructors
func _init(_team: int, _color: Color, _food: int, _gold: int) -> void:
	team = _team
	color = _color
	food = _food
	gold = _gold
