extends Entity
class_name ResourceNode

#Fields
export var resource_yield = 1
export var remaining_charges = 20
export var basic : bool
var resource_type : int


#Constructors
func _init(_resource_type: int):
	resource_type = _resource_type
