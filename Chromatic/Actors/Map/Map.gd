extends Node
class_name Map

#UI Scenes
var building_health_bar_scene = preload("res://UI/HealthBars/BuildingHealthBar/BuildingHealthBar.tscn")
var building_construction_timer_scene = preload("res://UI/ConstructionTimer/ConstructionTimer.tscn")

#Unit Scenes
var settler_scene = preload("res://Actors/Units/Settler/Settler.tscn")
var worker_scene = preload("res://Actors/Units/Worker/Worker.tscn")
var warrior_scene = preload("res://Actors/Units/Warrior/Warrior.tscn")
var archer_scene = preload("res://Actors/Units/Archer/Archer.tscn")

#Building Scenes
var settlement_scene = preload("res://Actors/Buildings/Settlement/Settlement.tscn")
var outpost_scene = preload("res://Actors/Buildings/Outpost/Outpost.tscn")
var hunting_camp_scene = preload("res://Actors/Buildings/HuntingCamp/HuntingCamp.tscn")
var mining_camp_scene = preload("res://Actors/Buildings/MiningCamp/MiningCamp.tscn")

#Resource Scenes
var food_scene = preload("res://Actors/ResourceNodes/Food/Food.tscn")
var gold_scene = preload("res://Actors/ResourceNodes/Gold/Gold.tscn")

#Constants
const TILE_DIAMETER = 64
const STARTING_FOOD = 5
const STARTING_GOLD = 0

#Enums
enum BATTLE_RESULT { CANCELLED, NONE_DIED, ATTACKER_DIED, DEFENDER_DIED, BOTH_DIED }
enum Z_INDEX { RESOURCE_NODE, BUILDING, UNIT }

#Fields
var rows = 8
var columns = 10
var selected_entity : Entity
var selected_ability : Ability
var board = Board.new()
var game_turn = 1
var player_turn = 1
var number_of_players = 2
var units : Array
var buildings : Array
var resource_nodes : Array
var players = {}
var multiple_entity_selection_storage : Array

#Signals
signal entity_selected
signal multiple_entities_selected
signal entity_deselected
signal new_player_turn
signal new_game_turn
signal resource_updated
signal action_points_updated


#Event Handlers
func _on_tile_clicked(coordinates : Vector2) -> void:
	if !board.get_tile(coordinates).fog_of_war:
		_select_entity_at_tile(coordinates)


func _on_tile_hovered(coordinates: Vector2) -> void:
	var tile = board.get_tile(coordinates)
	if selected_ability:
		var valid = selected_ability.validate_target(tile, selected_entity)
		var hover_filter_color = Color(0, 1, 0) if valid else Color(1, 0, 0)
		tile.show_hover_filter(hover_filter_color)
		
		if Input.is_mouse_button_pressed(BUTTON_RIGHT):
			board.clear_tile_path()
			if selected_entity && selected_entity is Unit:
				board.map_path(selected_entity.coordinates, coordinates)
	else:
		tile.show_hover_filter()


func _on_tile_unhovered(coordinates: Vector2) -> void:
	var tile = board.get_tile(coordinates)
	if selected_ability:
		pass
	else:
		tile.hide_hover_filter()


func _on_tile_right_clicked(coordinates: Vector2) -> void:
	var dest_tile = board.get_tile(coordinates)
	if !dest_tile.fog_of_war && dest_tile.occupant:
		return
	
	if selected_entity && selected_entity is Unit:
		board.map_path(selected_entity.coordinates, coordinates)


func _on_tile_right_mouse_released(coordinates: Vector2) -> void:
	if !selected_entity || !selected_entity is Unit:
		return
		
	var selected_unit = selected_entity
	
	var tile = board.get_tile(coordinates)
	
	if tile.fog_of_war:
		_traverse_to_path(selected_unit, coordinates.x, coordinates.y)
		return
	
	#Hostile player entity
	if tile.has_hostile_player_entity(player_turn):
		if !selected_unit.can_attack:
			print("This unit cannot attack")
			return
		
		if selected_unit.current_action_points <= 0:
			print("Unit has no remaining action points to attack")
			return
		
		var hostile_player_entity = tile.building if tile.has_hostile_building(player_turn) else tile.occupant
		
		var battle_result = _attack(selected_unit, hostile_player_entity)
		if battle_result != BATTLE_RESULT.CANCELLED:
			_resolve_attack(selected_unit, hostile_player_entity, battle_result)
			_spend_remaining_action_points(selected_unit)
		
		return
	
	#No units or hostile buildings
	if !tile.occupant && !tile.has_hostile_building(player_turn):
		_traverse_to_path(selected_unit, coordinates.x, coordinates.y)
		
		if selected_unit is Worker && selected_unit.is_constructing:
			_try_set_worker_construction(selected_unit, false)
		return


func _on_EndTurnButton_pressed() -> void:
	_end_turn()


func _on_AbilityBar_ability_pressed(index: int) -> void:
	if selected_entity is Building && selected_entity.under_construction:
		print("Building cannot use ability while under construction")
		return
	
	var ability = selected_entity.abilities[index]
	if !ability:
		print("Ability index " + str(index) + " not found on entity")
	
	selected_ability = ability
	
#	var player = players[player_turn]
#	if player.food < ability.food_cost:
#		print("Insufficient food")
#		return
#
#	if player.gold < ability.gold_cost:
#		print("Insufficient gold")
#		return
#
#	player.food -= ability.food_cost
#	player.gold -= ability.gold_cost
#
#	if ability.cast_time > 0:
#		selected_entity.queue_ability(index)
#	else:
#		_cast_ability(ability, selected_entity)


func _on_EntitySelectionDropdown_option_selected(index: int) -> void:
	_select_entity(multiple_entity_selection_storage[index])


func _on_Player_resource_update(resource_type: int, value: int) -> void:
	emit_signal("resource_updated", resource_type, value)


#Methods
func _ready() -> void:
	#TODO - food test code
	for i in range(0, number_of_players):
		var team = i + 1
		var player = Player.new(team, Lookups.TEAM_COLORS[team], STARTING_FOOD, STARTING_GOLD)
		player.connect("resource_updated", self, "_on_Player_resource_update")
		players[team] = player
	
	add_child(board)
	board.generate_test_map(columns, rows)
	
	for tile in board.get_all_tiles():
		tile.connect("tile_clicked", self, "_on_tile_clicked")
		tile.connect("tile_right_clicked", self, "_on_tile_right_clicked")
		tile.connect("tile_hovered", self, "_on_tile_hovered")
		tile.connect("tile_unhovered", self, "_on_tile_unhovered")
		tile.connect("tile_right_mouse_released", self, "_on_tile_right_mouse_released")
	
	_spawn_unit(Enums.UNIT_TYPE.SETTLER, "Settler", Vector2(0, 0), 1)
	_spawn_unit(Enums.UNIT_TYPE.ARCHER, "Archer", Vector2(7, 7), 1)
	_spawn_unit(Enums.UNIT_TYPE.WARRIOR, "Warrior", Vector2(5,5 ), 2)
	_spawn_unit(Enums.UNIT_TYPE.WORKER, "Worker", Vector2(3, 1), 2)
	_spawn_unit(Enums.UNIT_TYPE.SETTLER, "Settler", Vector2(1, 0), 2)
	
	_spawn_resource_node(Enums.RESOURCE_TYPE.FOOD, "Food", Vector2(6, 1))
	_spawn_resource_node(Enums.RESOURCE_TYPE.GOLD, "Gold", Vector2(8, 3))
	board.refresh_fog_of_war_for_team(1)
	board.set_astar_routing(1)
	
	emit_signal("new_player_turn", players[1])


func _process(_delta: float) -> void:
	if Input.is_action_just_released("right_mouse"):
		board.clear_tile_path()
		
	if Input.is_action_just_pressed("cancel"):
		_deselect_entity()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.scancode == KEY_1:
			board.refresh_fog_of_war_for_team(1)
		if event.scancode == KEY_2:
			board.refresh_fog_of_war_for_team(2)
		if event.scancode == KEY_3:
			board.refresh_fog_of_war_for_team(-1)		


func _get_tiles(tile_set_coordinates: PoolVector2Array) -> Array:
	var result = []
	
	for tile_coordinates in tile_set_coordinates:
		var tile = board.get_tile(tile_coordinates)
		if tile:
			result.push_back(tile)
	
	return result


func _traverse_to_path(unit, x, y) -> void:
	board.get_tile(unit.coordinates).hide_yellow_filter()
	var point_path = board.get_movement_path(unit.coordinates, Vector2(x, y))
	
	var i = 0
	for point in point_path:
		if unit.current_action_points <= 0:
			print("Unit has no more action points")
			return
		
		if !board.try_place_unit(unit, point):
			print("Failed to place unit while traversing path - cancelling traversal")
			break;
		
		board.refresh_fog_of_war_for_team(player_turn)
		unit.current_action_points -= 1
		emit_signal("action_points_updated", unit.current_action_points, unit.max_action_points)
		
		var has_discovered_unit = false
		for discovered_tile in board.get_last_discovered_tiles_for_team(unit.team):
			if discovered_tile.occupant && discovered_tile.occupant.team != unit.team:
				has_discovered_unit = true
		
		if has_discovered_unit:
			board.set_astar_routing(player_turn)
			
			if i != point_path.size() - 1:
				print("Enemy unit discovered on path - cancelling out of traversal early")
				break
		
		i += 1
	
	board.get_tile(unit.coordinates).show_yellow_filter()
	board.clear_tile_path()


func _end_turn() -> void:
	player_turn += 1
	if player_turn > number_of_players:
		player_turn = 1
		game_turn += 1
		_resolve_game_turn()
		
	board.refresh_fog_of_war_for_team(player_turn)
	board.set_astar_routing(player_turn)
	_deselect_entity()
	emit_signal("new_player_turn", players[player_turn])


func _try_set_worker_construction(worker: Worker, construct: bool) -> bool:
	if construct == false:
		worker.is_constructing = false
		print("Worker is no longer constructing")
		return true
	
	var worker_tile = board.get_tile(worker.coordinates)
	
	if !worker_tile:
		return false
	
	if worker_tile.building == null:
		print("No building to construct")
		return false
	
	if !worker_tile.building.under_construction || !worker_tile.building.construction_requires_worker:
		print("Cannot construct that building")
		return false
	
	else:
		worker.is_constructing = true
		print("Worker now constructing")
	
	return true


func _select_entity_at_tile(coordinates: Vector2) -> void:
	var tile = board.get_tile(coordinates)
	
	if !tile:
		return
	
	var tile_entities = []
	if tile.occupant && tile.occupant.team == player_turn:
		tile_entities.push_front(tile.occupant)
	if tile.building && tile.building.team == player_turn:
		tile_entities.push_front(tile.building)
	if tile.resource_node:
		tile_entities.push_front(tile.resource_node)
		
	if tile_entities.size() <= 0:
		print("Nothing to select")
		return
		
	if tile_entities.size() == 1:
		print("One entity to select")
		_select_entity(tile_entities[0])
		return
	
	print("Multiple entities available to select")
	multiple_entity_selection_storage = [ tile.occupant, tile.building, tile.resource_node ]
	emit_signal("multiple_entities_selected", tile.occupant, tile.building, tile.resource_node)


func _select_entity(entity: Entity):
	if selected_entity:
		board.get_tile(selected_entity.coordinates).hide_yellow_filter()
		
	selected_entity = entity
	board.get_tile(selected_entity.coordinates).show_yellow_filter()
	
	emit_signal("entity_selected", selected_entity)


func _deselect_entity() -> void:
	if !selected_entity:
		return

	var selected_entity_tile = board.get_tile(selected_entity.coordinates)
	selected_entity_tile.hide_yellow_filter()
	selected_entity = null
	selected_ability = null
	emit_signal("entity_deselected")


func _spawn_unit(unit_type: int, unit_name: String, coordinates: Vector2, team: int) -> Unit:
	var unit
	
	match unit_type:
		Enums.UNIT_TYPE.SETTLER:
			unit = settler_scene.instance()
			unit.abilities.push_front(AbilityFactory.get_construct_settlement_ability())
			
		Enums.UNIT_TYPE.WORKER:
			unit = worker_scene.instance()
			unit.abilities.push_back(AbilityFactory.get_construct_outpost_ability())
			unit.abilities.push_back(AbilityFactory.get_construct_hunting_camp_ability())
			unit.abilities.push_back(AbilityFactory.get_construct_mining_camp_ability())
			unit.abilities.push_back(AbilityFactory.get_resume_construction_ability())
			
		Enums.UNIT_TYPE.WARRIOR:
			unit = warrior_scene.instance()
			
		Enums.UNIT_TYPE.ARCHER:
			unit = archer_scene.instance()
		_:
			print("Cannot locate unit type " + str(unit_type) + " to spawn")
			return null
	unit.team = team
	unit.z_index = Z_INDEX.UNIT
	unit.set_name(unit_name)
	add_child(unit)
	
	var success = board.try_place_unit(unit, coordinates)
	
	if !success:
		print("Failed to place unit at " + str(coordinates))
		unit.queue_free()
		return null
	
	board.refresh_fog_of_war_for_team(player_turn)
	units.push_front(unit)
	
	return unit


func _spawn_building(building_type: int, building_name: String, coordinates: Vector2, team: int) -> Building:
	var dest_tile = board.get_tile(coordinates)
	if dest_tile.building:
		print("Cannot build on tile " + str(dest_tile.coordinates) + ". A building already exists there!")
		return null
	
	var building
	
	match building_type:
		Enums.BUILDING_TYPE.SETTLEMENT:
			building = settlement_scene.instance()
			building.abilities.push_front(AbilityFactory.get_build_settler_ability())
		Enums.BUILDING_TYPE.OUTPOST:
			building = outpost_scene.instance()
		Enums.BUILDING_TYPE.HUNTING_CAMP:
			if dest_tile.resource_node == null || dest_tile.resource_node.resource_type != Enums.RESOURCE_TYPE.FOOD:
				print("Cannot build a hunting camp there")
				return null
				
			building = hunting_camp_scene.instance()
		Enums.BUILDING_TYPE.MINING_CAMP:
			if dest_tile.resource_node == null || dest_tile.resource_node.resource_type != Enums.RESOURCE_TYPE.GOLD:
				print("Cannot build a mining camp there")
				return null
				
			building = mining_camp_scene.instance()
		_:
			print("Cannot locate building type " + str(building_type) + " to spawn")
			return null
	
	if building.requires_territory && dest_tile.claimed_by != team:
		print("Building must be placed in your territory")
		return null
		
	var building_health_bar = building_health_bar_scene.instance()
	building_health_bar.margin_left = -35
	building_health_bar.margin_top = -20
	building_health_bar.margin_right = -23
	building_health_bar.margin_bottom = 20
	building_health_bar.name = "HealthBar"
	building.add_child(building_health_bar)
	
	var building_construction_timer = building_construction_timer_scene.instance()
	building_construction_timer.margin_left = -16
	building_construction_timer.margin_top = 28
	building_construction_timer.margin_right = -16
	building_construction_timer.margin_bottom = 28
	building.add_child(building_construction_timer)
	
	building.z_index = Z_INDEX.BUILDING
	building.team = team
	building.set_name(building_name)
	building.current_vision_range = building.max_vision_range
	
	if !board.try_place_building(building, coordinates):
		print("Failed to place building at " + str(coordinates))
		return null
	
	add_child(building)
	buildings.push_front(building)
	board.update_entity_vision_counters(building)
	board.refresh_fog_of_war_for_team(player_turn)
	
	return building


func _spawn_resource_node(resource_type: int, resource_name: String, coordinates: Vector2) -> ResourceNode:
	var resource_node
	
	match resource_type:
		Enums.RESOURCE_TYPE.FOOD:
			resource_node = food_scene.instance()
		Enums.RESOURCE_TYPE.GOLD:
			resource_node = gold_scene.instance()
		_:
			print("Cannot locate resource type " + str(resource_type) + " to spawn")
			return null
	
	var success = board.try_place_resource_node(resource_node, coordinates)
	
	if !success:
		print("Failed to place resource node at " + str(coordinates))
		return null
	
	resource_node.z_index = Z_INDEX.RESOURCE_NODE
	resource_node.set_name(resource_name)
	resource_nodes.push_front(resource_node)
	add_child(resource_node)
	
	return resource_node


func _despawn_entity(entity: Entity) -> void:
	var occupying_tile = board.get_tile(entity.coordinates)
	
	if entity is Unit:
		occupying_tile.occupant = null
		units.erase(entity)
		if entity.team != player_turn:
			board.set_astar_routing(player_turn)
	
	if entity is Building:
		occupying_tile.building = null	
		buildings.erase(entity)
	
	if entity is ResourceNode:
		occupying_tile.resource_node = null	
		resource_nodes.erase(entity)
	
	if selected_entity == entity:
		_deselect_entity()
	
	if !entity is ResourceNode:
		board.clear_player_entity_vision(entity)
	
	entity.queue_free()


func _resolve_game_turn() -> void:
	for building in buildings:
		#Resolve construction
		if building.under_construction:
			var building_tile = board.get_tile(building.coordinates)
			if !building.construction_requires_worker || building_tile.has_constructing_worker():
				building.build_time_remaining -= 1
			
			if building.build_time_remaining <= 0:
				board.clear_player_entity_vision(building)
				building.under_construction = false
				board.update_entity_vision_counters(building)
				
				if building_tile.has_constructing_worker():
					_try_set_worker_construction(building_tile.occupant, false)
				
				if building is Settlement:
					var tiles_to_claim = Tile.get_tiles_in_radius(building.coordinates, 2)
					_try_claim_tiles(tiles_to_claim, building.team)
					
		
		#Resolve queued abilities
		var ability = building.ability_queue_next()
		if ability:
			_cast_ability(ability, building)
				
	for resource_node in resource_nodes:
		var tile = board.get_tile(resource_node.coordinates)
		
		if tile.is_harvesting():
			var harvested_resources = tile.pop_resources()
			
			match harvested_resources[0]:
				Enums.RESOURCE_TYPE.FOOD:
					players[tile.claimed_by].food += harvested_resources[1]
					print("Team " + str(tile.claimed_by) + " claimed " + str(harvested_resources[1]) + " food")
				Enums.RESOURCE_TYPE.GOLD:
					players[tile.claimed_by].gold += harvested_resources[1]
					print("Team " + str(tile.claimed_by) + " claimed " + str(harvested_resources[1]) + " gold")
			
			if resource_node.remaining_charges <= 0:
				print("Resource node mined out")
				_despawn_entity(resource_node)
	
	for unit in units:
		unit.current_action_points = unit.max_action_points


func _spend_remaining_action_points(unit: Unit):
	unit.current_action_points = 0
	emit_signal("action_points_updated", unit.current_action_points, unit.max_action_points)


func _cast_ability(ability: Ability, caster: PlayerEntity) -> void:
	var successful = false
	
	if caster is Unit && caster.current_action_points <= 0:
		print("Unit has no remaining action points")
		return
	
	match ability.type:
		Enums.ABILITY_TYPES.CONSTRUCT_BUILDING:
			var building_type = ability.data.building_type
			var building_name = ability.data.building_name
			var coordinates = caster.coordinates
			var team = caster.team
			
			if ability.data.building_type == Enums.BUILDING_TYPE.SETTLEMENT && caster is Settler:
				_despawn_entity(caster)
			
			var building = _spawn_building(building_type, building_name, coordinates, team)
			
			if !building:
				print("Failed to spawn building")
				return
			
			if building && building.construction_requires_worker:
				var tile = board.get_tile(caster.coordinates)
				_try_set_worker_construction(tile.occupant, true)
			
			successful = true
	
		Enums.ABILITY_TYPES.RESUME_CONSTRUCTION:
			successful = _try_set_worker_construction(caster, true)
	
		Enums.ABILITY_TYPES.BUILD_UNIT:
			var unit_type = ability.data.unit_type
			var unit_name = ability.data.unit_name
			var unit = _spawn_unit(unit_type, unit_name, caster.coordinates, caster.team)
			successful = true
		
		_:
			print("Ability type not recognised")
		
	if successful && caster is Unit:
		_spend_remaining_action_points(caster)


func _try_claim_tiles(coordinates: Array, team: int):
	for tile in coordinates:
		board.try_claim_tile(tile, team)


#Returns an enum flag indicating who died in the battle
func _attack(attacker: PlayerEntity, defender: PlayerEntity) -> int:
	var distance = board.get_combat_path(attacker.coordinates, defender.coordinates).size()
	var is_ranged_attack = attacker.attack_range > 0
	
	if is_ranged_attack:
		if attacker.attack_range < distance:
			print("Out of ranged attack range")
			return BATTLE_RESULT.CANCELLED
		
		_deal_ranged_damage(attacker, defender)
		if defender.attack_range >= distance: #ranged counter attack
			_deal_ranged_damage(defender, attacker)
	else:
		if distance > 1:
			print("Out of melee attack range")
			return BATTLE_RESULT.CANCELLED
			
		_deal_melee_damage(attacker, defender)
		_deal_melee_damage(defender, attacker)

	var attacker_died = attacker.current_health == 0
	var defender_died = defender.current_health == 0

	var result = BATTLE_RESULT.NONE_DIED

	if attacker_died && defender_died:
		result = BATTLE_RESULT.BOTH_DIED
	elif attacker_died:
		result = BATTLE_RESULT.ATTACKER_DIED
	elif defender_died:
		result = BATTLE_RESULT.DEFENDER_DIED
	
	return result


func _deal_melee_damage(from: PlayerEntity, to: PlayerEntity):
	to.current_health -= from.melee_attack_damage


func _deal_ranged_damage(from: PlayerEntity, to: PlayerEntity):
	to.current_health -= from.ranged_attack_damage


#Resolves the units based on the battle result enum from the _attack method
func _resolve_attack(attacker: PlayerEntity, defender: PlayerEntity, battle_result: int):
	if battle_result == BATTLE_RESULT.ATTACKER_DIED:
		_despawn_entity(attacker)
		
	if battle_result == BATTLE_RESULT.DEFENDER_DIED:
		var defender_tile = board.get_tile(defender.coordinates)
		_despawn_entity(defender)
		if attacker.attack_range == 0:
			_traverse_to_path(attacker, defender_tile.coordinates.x, defender_tile.coordinates.y)
	
	if battle_result == BATTLE_RESULT.BOTH_DIED:
		_despawn_entity(attacker)
		_despawn_entity(defender)
