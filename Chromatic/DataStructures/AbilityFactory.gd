extends Node
class_name AbilityFactory


#Unit Abilities
static func get_construct_settlement_ability() -> Ability:
	var construct_settlement_icon = load("res://Assets/Buildings/Settlement.png")
	var data = {
		"building_type": Enums.BUILDING_TYPE.SETTLEMENT,
		"building_name": "Settlement"
	}
	var target_reqs = [Enums.REQUIREMENTS.UNOCCUPIED]
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, data, 0, target_reqs, construct_settlement_icon)
			

static func get_construct_outpost_ability() -> Ability:
	var construct_outpost_icon = load("res://Assets/Buildings/Outpost.png")
	var construct_outpost_data = {
		"building_type": Enums.BUILDING_TYPE.OUTPOST,
		"building_name": "Outpost"
	}
	var target_reqs = [Enums.REQUIREMENTS.UNOCCUPIED]
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, construct_outpost_data, 1, target_reqs, construct_outpost_icon)


static func get_construct_hunting_camp_ability() -> Ability:
	var construct_hunting_camp_icon = load("res://Assets/Buildings/HuntingCamp.png")
	var construct_hunting_camp_data = {
		"building_type": Enums.BUILDING_TYPE.HUNTING_CAMP,
		"building_name": "HuntingCamp"
	}
	var target_reqs = [Enums.REQUIREMENTS.UNOCCUPIED, Enums.REQUIREMENTS.FOOD]
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, construct_hunting_camp_data, 1, target_reqs, construct_hunting_camp_icon)


static func get_construct_mining_camp_ability() -> Ability:
	var construct_mining_camp_icon = load("res://Assets/Buildings/MiningCamp.png")
	var construct_mining_camp_data = {
		"building_type": Enums.BUILDING_TYPE.MINING_CAMP,
		"building_name": "MiningCamp"
	}
	var target_reqs = [Enums.REQUIREMENTS.UNOCCUPIED, Enums.REQUIREMENTS.GOLD]
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, construct_mining_camp_data, 1, target_reqs, construct_mining_camp_icon)

#Building Abilities
static func get_build_settler_ability() -> Ability:
	var build_settler_icon = load("res://Assets/Units/Settler.png")
	var build_settler_data = {
		"unit_type": Enums.UNIT_TYPE.SETTLER,
		"unit_name": "Settler"
	}
	var target_reqs = [Enums.REQUIREMENTS.UNOCCUPIED]
	var production_time = 1
	var food_cost = 1
	return Ability.new(Enums.ABILITY_TYPES.BUILD_UNIT, build_settler_data, 1, target_reqs, build_settler_icon, production_time, food_cost)
