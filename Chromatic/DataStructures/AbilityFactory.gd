extends Node
class_name AbilityFactory


#Unit Abilities
static func get_construct_settlement_ability() -> Ability:
	var construct_settlement_icon = load("res://Assets/Buildings/Settlement.png")
	var data = {
		"building_type": Enums.BUILDING_TYPE.SETTLEMENT,
		"building_name": "Settlement"
	}
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, data, Enums.TARGET_TYPE.EMPTY, construct_settlement_icon)
			

static func get_construct_outpost_ability() -> Ability:
	var construct_outpost_icon = load("res://Assets/Buildings/Outpost.png")
	var construct_outpost_data = {
		"building_type": Enums.BUILDING_TYPE.OUTPOST,
		"building_name": "Outpost"
	}
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, construct_outpost_data, Enums.TARGET_TYPE.EMPTY, construct_outpost_icon)


static func get_construct_hunting_camp_ability() -> Ability:
	var construct_hunting_camp_icon = load("res://Assets/Buildings/HuntingCamp.png")
	var construct_hunting_camp_data = {
		"building_type": Enums.BUILDING_TYPE.HUNTING_CAMP,
		"building_name": "HuntingCamp"
	}
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, construct_hunting_camp_data, Enums.TARGET_TYPE.EMPTY, construct_hunting_camp_icon)


static func get_construct_mining_camp_ability() -> Ability:
	var construct_mining_camp_icon = load("res://Assets/Buildings/MiningCamp.png")
	var construct_mining_camp_data = {
		"building_type": Enums.BUILDING_TYPE.MINING_CAMP,
		"building_name": "MiningCamp"
	}
	return Ability.new(Enums.ABILITY_TYPES.CONSTRUCT_BUILDING, construct_mining_camp_data, Enums.TARGET_TYPE.EMPTY, construct_mining_camp_icon)


static func get_resume_construction_ability() -> Ability:
	var resume_construction_icon = load("res://Assets/AbilityIcons/ResumeConstruction.png")
	var resume_construction_data = {}
	return Ability.new(Enums.ABILITY_TYPES.RESUME_CONSTRUCTION, resume_construction_data, Enums.TARGET_TYPE.FRIENDLY_BUILDING, resume_construction_icon)


#Building Abilities
static func get_build_settler_ability() -> Ability:
	var build_settler_icon = load("res://Assets/Units/Settler.png")
	var build_settler_data = {
		"unit_type": Enums.UNIT_TYPE.SETTLER,
		"unit_name": "Settler"
	}
	var production_time = 1
	var food_cost = 1
	return Ability.new(Enums.ABILITY_TYPES.BUILD_UNIT, build_settler_data, Enums.TARGET_TYPE.EMPTY, build_settler_icon, production_time, food_cost)
