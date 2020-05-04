extends Node
class_name Ability

#Fields
var type: int
var data: Dictionary
var cast_range: int
var target_requirements: Array
var icon: Texture
var cast_time: int
var food_cost: int
var gold_cost: int


#Constructors
func _init(_type: int, _data: Dictionary, _cast_range: int, _target_requirements: Array, _icon: Texture, _cast_time = 0, _food_cost = 0, _gold_cost = 0) -> void:
	type = _type
	data = _data
	cast_range = _cast_range
	target_requirements = _target_requirements
	icon = _icon
	cast_time = _cast_time
	food_cost = _food_cost
	gold_cost = _gold_cost


#Methods

# _type ommited to avoid cyclical dependancy
func validate_target(target_tile, caster, abs_distance) -> bool:
	if cast_range < abs_distance: #out of range
		return false
	
	return TargetValidator.validate(target_tile, caster, target_requirements)


# _type ommited to avoid cyclical dependancy
func execute(target_tile, caster) -> bool:
	return true
	#execute ability on target tile
