extends Entity
class_name ResourceNode

#Fields
export var quantity = 1
export var remaining_charges = 20
var resource_type: int


#Constructors
func _init(_resource_type: int):
	resource_type = _resource_type
