extends Actor
class_name ResourceNode

#Fields
export var quantity = 1
export var remaining_charges = 20
var resource_type: int


#Constructors
func _init(resource_type: int):
	self.resource_type = resource_type
