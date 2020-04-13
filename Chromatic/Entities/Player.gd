extends Node
class_name Player

var team : int
var food : int

#Constructors
func _init(team: int, food: int) -> void:
	self.team = team
	self.food = food
