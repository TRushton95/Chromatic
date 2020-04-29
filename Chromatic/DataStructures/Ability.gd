extends Node
class_name Ability

#Fields
var type: int
var data: Dictionary
var target_type: int
var icon: Texture
var cast_time: int
var food_cost: int
var gold_cost: int


#Constructors
func _init(_type: int, _data: Dictionary, _target_type: int, _icon: Texture, _cast_time = 0, _food_cost = 0, _gold_cost = 0) -> void:
	type = _type
	data = _data
	target_type = _target_type
	icon = _icon
	cast_time = _cast_time
	food_cost = _food_cost
	gold_cost = _gold_cost


#Methods

# _type ommited to avoid cyclical dependancy
func validate_target(target_tile, caster) -> bool:
	return TargetValidator.validate(target_tile, caster, target_type)


# _type ommited to avoid cyclical dependancy
func execute(target_tile, caster) -> bool:
	if !validate_target(target_tile, caster):
		print("Failed to execute ability on that target")
		return false
	
	return true
	#execute ability on target tile
