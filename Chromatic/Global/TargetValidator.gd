extends Node

#Enums
enum ALLIANCE { ANY, FRIENDLY, HOSTILE }


#Methods
func validate(target_tile: Tile, caster: PlayerEntity, target_type: int) -> bool:
	var result = false
	
	match target_type:
		Enums.TARGET_TYPE.ANY:
			result = true
		
		Enums.TARGET_TYPE.EMPTY:
			result = _validate_empty_tile(target_tile, caster)
		
		Enums.TARGET_TYPE.FRIENDLY_UNIT:
			result = _validate_unit(target_tile, caster, ALLIANCE.FRIENDLY)
	
		Enums.TARGET_TYPE.FRIENDLY_BUILDING:
			result = _validate_building(target_tile, caster, ALLIANCE.FRIENDLY)
			
#		Enums.TARGET_TYPE.FRIENDLY_PLAYER_ENTITY:
#			result = _validate_player_entity(target_tile, caster, ALLIANCE.FRIENDLY)
		
		Enums.TARGET_TYPE.HOSTILE_UNIT:
			result = _validate_unit(target_tile, caster, ALLIANCE.HOSTILE)
		
		Enums.TARGET_TYPE.HOSTILE_BUILDING:
			result = _validate_building(target_tile, caster, ALLIANCE.HOSTILE)
		
#		Enums.TARGET_TYPE.HOSTILE_PLAYER_ENTITY:
#			result = _validate_player_entity(target_tile, caster, ALLIANCE.HOSTILE)
	
	return result


func _validate_empty_tile(target_tile: Tile, caster: PlayerEntity) -> bool:
	if target_tile.occupant == null && target_tile.building == null:
		return true
	
	return false


func _validate_unit(target_tile: Tile, caster: PlayerEntity, alliance: int) -> bool:
	var result = false
	
	var target_unit = target_tile.occupant
	if target_unit && target_unit is Unit:
		match alliance:
			ALLIANCE.ANY:
				result = true
			ALLIANCE.FRIENDLY:
				result = target_unit.team == caster.team
			ALLIANCE.HOSTILE:
				result = target_unit.team != caster.team
	
	return result


func _validate_building(target_tile: Tile, caster: PlayerEntity, alliance: int) -> bool:
	var result = false
	
	var target_building = target_tile.building
	if target_building && target_building is Building:
		match alliance:
			ALLIANCE.ANY:
				result = true
			ALLIANCE.FRIENDLY:
				result = target_building.team == caster.team
			ALLIANCE.HOSTILE:
				result = target_building.team != caster.team
	
	return result


func _validate_resource_node(target_tile: Tile, caster: PlayerEntity) -> bool:
	var target_resource_node = target_tile.resource_node
	if target_resource_node && target_resource_node is ResourceNode:
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
