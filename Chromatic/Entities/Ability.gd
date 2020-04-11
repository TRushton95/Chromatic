extends Node
class_name Ability

#Fields
var type: int
var data: Dictionary
var icon: Texture


#Constructors
func _init(type: int, data: Dictionary, icon: Texture) -> void:
	self.type = type
	self.data = data
	self.icon = icon
