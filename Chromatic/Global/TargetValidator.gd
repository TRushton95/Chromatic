extends Node

#Methods
func validate(target_tile: Tile, caster: PlayerEntity, target_requirements: Array) -> bool:
	for requirement in target_requirements:
		var meets_requirement = false
		
		match requirement:
			Enums.REQUIREMENTS.UNOCCUPIED:
				meets_requirement = _validate_unoccupied_tile(target_tile, caster)
			Enums.REQUIREMENTS.UNIT:
				meets_requirement = _validate_unit(target_tile, caster)
			Enums.REQUIREMENTS.BUILDING:
				meets_requirement = _validate_building(target_tile, caster)
			Enums.REQUIREMENTS.GOLD:
				meets_requirement = _validate_gold(target_tile, caster)
			Enums.REQUIREMENTS.FOOD:
				meets_requirement = _validate_food(target_tile, caster)
		
		if !meets_requirement:
			print("Failed to meet targeting requirement " + str(requirement))
			return false
				
	return true


func _validate_unoccupied_tile(target_tile: Tile, caster: PlayerEntity) -> bool:
	if target_tile.occupant == null && target_tile.building == null:
		return true
	
	return false


func _validate_unit(target_tile: Tile, caster: PlayerEntity) -> bool:
	var result = false
	
	var target_unit = target_tile.occupant
	if target_unit && target_unit is Unit:
		result = true
	
	return result


func _validate_building(target_tile: Tile, caster: PlayerEntity) -> bool:
	var result = false
	
	var target_building = target_tile.building
	if target_building && target_building is Building:
		result = true
	
	return result


func _validate_food(target_tile: Tile, caster: PlayerEntity) -> bool:
	var target_resource_node = target_tile.resource_node
	if target_resource_node && target_resource_node is Food:
		return true
	
	return false


func _validate_gold(target_tile: Tile, caster: PlayerEntity) -> bool:
	var target_resource_node = target_tile.resource_node
	if target_resource_node && target_resource_node is Gold:
		return true
	
	return false

# NEEDS TO BE DONE AFTER UNIT/BUILDING REFACTOR INTO ONE ENTITY
#func _validate_player_entity(target_tile: Tile, caster: PlayerEntity, alliance = Enums.ALLIANCE.NA) -> bool:
#
#	var valid_unit = _validate_unit(target_tile, caster)
#	var valid_building = _validate_building(target_tile, caster)
#	if valid_unit || valid_building:
#		return true
#
#	return false
