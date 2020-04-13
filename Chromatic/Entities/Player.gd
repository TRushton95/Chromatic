extends Node
class_name Player

var team : int
var color: Color
var food : int

#Constructors
func _init(team: int, color: Color, food: int) -> void:
	self.team = team
	self.color = color
	self.food = food
