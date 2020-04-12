extends Node
class_name Map

#Scenes
var tile_scene = preload("res://Actors/Tiles/Tile.tscn")

#Unit Scenes
var settler_scene = preload("res://Actors/Units/Settler/Settler.tscn")
var worker_scene = preload("res://Actors/Units/Worker/Worker.tscn")
var warrior_scene = preload("res://Actors/Units/Warrior/Warrior.tscn")
var archer_scene = preload("res://Actors/Units/Archer/Archer.tscn")

#Building Scenes
var settlement_scene = preload("res://Actors/Buildings/Settlement/Settlement.tscn")
var outpost_scene = preload("res://Actors/Buildings/Outpost/Outpost.tscn")

#Data Structures
const Ability = preload("res://Entities/Ability.gd")

#Constants
const TILE_DIAMETER = 64

#Enums
enum UNIT_TYPE { SETTLER, WORKER, WARRIOR, ARCHER }
enum BUILDING_TYPE { SETTLEMENT, OUTPOST }
enum BATTLE_RESULT { CANCELLED, NONE_DIED, ATTACKER_DIED, DEFENDER_DIED, BOTH_DIED }
enum ABILITY_TYPES { CONSTRUCT_BUILDING }

#Fields
var rows = 8
var columns = 10
var selected_unit : Unit
var tile_lookup = {}
var astar = AStar2D.new()
var tile_path_highlight = []
var previous_hovered_tile : Tile
var game_turn = 1
var player_turn = 1
var number_of_players = 2
var buildings : Array

#Signals
signal unit_selected
signal unit_deselected
signal new_player_turn
signal new_game_turn


#Event Handlers
func _on_tile_clicked(coordinates : Vector2) -> void:
	var tile = _get_tile(coordinates)
	
	if !tile || !tile.occupant || tile.occupant.team != player_turn:
		return
	
	_select_unit_at_tile(coordinates)


func _on_tile_hovered(coordinates: Vector2) -> void:
	var hovered_tile = _get_tile(coordinates)
#	if hovered_tile && hovered_tile.occupant != null:
#		hovered_tile.occupant.show_health_bar()
		
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		_clear_tile_path()
		if selected_unit:
			_map_path(selected_unit.coordinates, coordinates)


func _on_tile_unhovered(coordinates: Vector2) -> void:
	var hovered_tile = _get_tile(coordinates)
#	if hovered_tile && hovered_tile.occupant  && hovered_tile.occupant != selected_unit:
#		hovered_tile.occupant.hide_health_bar()


func _on_tile_right_clicked(coordinates: Vector2) -> void:
	if selected_unit:
		_map_path(selected_unit.coordinates, coordinates)


func _on_tile_right_mouse_released(coordinates: Vector2) -> void:
	if !selected_unit:
		return
	
	var target_tile = _get_tile(coordinates)
	
	if !target_tile.occupant:
		_traverse_to_path(selected_unit, coordinates.x, coordinates.y)
		return
	
	if selected_unit.team == target_tile.occupant.team:
		return
	
	if !selected_unit.can_attack:
		print("This unit cannot attack!")
		return
	
	var battle_result = _attack(selected_unit, target_tile.occupant)
	_resolve_attack(selected_unit, target_tile.occupant, battle_result)


func _on_EndTurnButton_pressed() -> void:
	_end_turn()


func _on_AbilityButton_ability_selected(ability_type: int, data: Dictionary) -> void:
	match ability_type:
		ABILITY_TYPES.CONSTRUCT_BUILDING:
			var building_type = data.building_type
			var building_name = data.building_name
			_spawn_building(building_type, building_name, selected_unit.coordinates, selected_unit.team)


#Methods
func _ready() -> void:
	_generate_test_map()
	_spawn_unit(UNIT_TYPE.SETTLER, "Settler", Vector2(0,0), 1)
	_spawn_unit(UNIT_TYPE.ARCHER, "Archer", Vector2(7, 7), 1)
	_spawn_unit(UNIT_TYPE.WARRIOR, "Warrior", Vector2(5,5), 2)
	_spawn_unit(UNIT_TYPE.WORKER, "Worker", Vector2(3, 1), 2)


func _process(_delta: float) -> void:
	if Input.is_action_just_released("right_mouse"):
		_clear_tile_path()
		
	if Input.is_action_just_pressed("cancel"):
		_deselect_unit()


func _generate_test_map():
	var id = 0
	
	for y in rows:
		for x in columns:
			var tile = tile_scene.instance()
			tile.set_name(_tile_name(Vector2(x, y)))
			tile.position = Vector2(x * TILE_DIAMETER, y * TILE_DIAMETER * 0.75)
			tile.position += Vector2(TILE_DIAMETER / 2.0, TILE_DIAMETER / 2.0) # offset from 0
			tile.coordinates = Vector2(x, y)
			tile.id = id
			
			var weight_scale = 1.0
			astar.add_point(tile.id, tile.coordinates, weight_scale)
			
			if y % 2 == 0: # offset x every other row
				tile.position += Vector2(TILE_DIAMETER / 2.0, 0)
			
			tile.connect("tile_clicked", self, "_on_tile_clicked")
			tile.connect("tile_right_clicked", self, "_on_tile_right_clicked")
			tile.connect("tile_hovered", self, "_on_tile_hovered")
			tile.connect("tile_unhovered", self, "_on_tile_unhovered")
			tile.connect("tile_right_mouse_released", self, "_on_tile_right_mouse_released")
			tile_lookup[_tile_name(Vector2(x, y))] = tile
			add_child(tile)
			
			id += 1
	
	for tile_key in tile_lookup:
		_connect_to_adjacent_tiles(tile_lookup[tile_key])
		


func _connect_to_adjacent_tiles(tile):
	for adj_tile_coords in tile.get_adjacent_tiles():
		var adj_tile_key = _tile_name(adj_tile_coords)
		
		if (tile_lookup.has(adj_tile_key)):
			var adj_tile = tile_lookup[adj_tile_key]
			astar.connect_points(tile.id, adj_tile.id)

func _tile_name(coordinates: Vector2) -> String:
	return "tile_" + str(coordinates.x) + "," + str(coordinates.y)


func _get_tile(coordinates: Vector2) -> Node:
	return get_node(_tile_name(coordinates))


func _try_place_building(building, dest_coordinates: Vector2) -> bool:
	var result = false
	
	var source_tile = _get_tile(building.coordinates)
	if source_tile:
		print("Building already placed and cannot be moved!")
		return false
	
	var destination_tile = _get_tile(dest_coordinates)
	
	if destination_tile && !destination_tile.building:
		destination_tile.building = building
		building.coordinates = destination_tile.coordinates
		building.position = destination_tile.position
		
		result = true
	
	return result


func _try_place_unit(unit, dest_coordinates) -> bool:
	var result = false
	var source_tile = _get_tile(unit.coordinates)
	var destination_tile = get_node(_tile_name(dest_coordinates))
	
	if destination_tile && !destination_tile.occupant:
		destination_tile.occupant = unit
		unit.coordinates = destination_tile.coordinates
		unit.position = destination_tile.position
		
		if source_tile:
			source_tile.occupant = null
			
		result = true
	
	return result


func _get_path(from, to) -> PoolVector2Array:
	var source_tile = get_node(_tile_name(from))
	var destination_tile = get_node(_tile_name(to))
	
	var result = astar.get_point_path(source_tile.id, destination_tile.id)
	result.remove(0) #Path includes source_tile
	
	return result


func _traverse_to_path(unit, x, y) -> void:
	_get_tile(unit.coordinates).hide_yellow_filter()
	var point_path = _get_path(unit.coordinates, Vector2(x, y))
	
	for point in point_path:
		_try_place_unit(unit, point)
	
	_get_tile(unit.coordinates).show_yellow_filter()
	_clear_tile_path()


func _clear_tile_path() -> void:
	for tile in tile_path_highlight:
		tile.hide_white_filter()
	
	tile_path_highlight.clear()


func _map_path(from: Vector2, to: Vector2) -> void:
	var point_path = _get_path(from, to)
	for point in point_path:
		var tile = _get_tile(point)
		tile.show_white_filter()
		tile_path_highlight.push_back(tile)


func _end_turn() -> void:
	player_turn += 1
	if player_turn > number_of_players:
		player_turn = 1
		game_turn += 1
		resolve_turn()
		
	_deselect_unit()
	emit_signal("new_player_turn", player_turn)


func _select_unit_at_tile(coordinates: Vector2) -> void:
	_deselect_unit()
	
	var tile = _get_tile(coordinates)
	selected_unit = tile.occupant
	tile.show_yellow_filter()
	emit_signal("unit_selected", tile.occupant)


func _deselect_unit() -> void:
	if !selected_unit:
		return
		
	var selected_unit_tile = _get_tile(selected_unit.coordinates)
	
	selected_unit_tile.hide_yellow_filter()
#	selected_unit.hide_health_bar()
	emit_signal("unit_deselected")


func _spawn_unit(unit_type: int, unit_name: String, coordinates: Vector2, team: int) -> void:
	var unit
	
	match unit_type:
		UNIT_TYPE.SETTLER:
			unit = settler_scene.instance()
			var construct_settlement_icon = load("res://Assets/Buildings/Settlement.png")
			var data = {
				"building_type": BUILDING_TYPE.SETTLEMENT,
				"building_name": "Settlement"
			}
			unit.ability = Ability.new(ABILITY_TYPES.CONSTRUCT_BUILDING, data, construct_settlement_icon)
			
		UNIT_TYPE.WORKER:
			unit = worker_scene.instance()
			var construct_outpost_icon = load("res://Assets/Buildings/Outpost.png")
			var data = {
				"building_type": BUILDING_TYPE.OUTPOST,
				"building_name": "Outpost"
			}
			unit.ability = Ability.new(ABILITY_TYPES.CONSTRUCT_BUILDING, data, construct_outpost_icon)
			
		UNIT_TYPE.WARRIOR:
			unit = warrior_scene.instance()
		UNIT_TYPE.ARCHER:
			unit = archer_scene.instance()
		_:
			print("Cannot locate unit type " + str(unit_type) + " to spawn")
			return
	
	var success = _try_place_unit(unit, coordinates)
	
	if !success:
		print("Failed to place unit at " + str(coordinates))
		return
	
	unit.team = team
	unit.set_name(unit_name)
	add_child(unit)

func _despawn_unit(unit: Unit) -> void:
	var occupying_tile = _get_tile(unit.coordinates)
	occupying_tile.occupant = null
	unit.queue_free()

func _spawn_building(building_type: int, building_name: String, coordinates: Vector2, team: int) -> void:
	var dest_tile = _get_tile(coordinates)
	if dest_tile.building:
		print("Cannot build on tile " + str(dest_tile.coordinates) + ". A building already exists there!")
		return
	
	var building
	
	match building_type:
		BUILDING_TYPE.SETTLEMENT:
			building = settlement_scene.instance()
		BUILDING_TYPE.OUTPOST:
			building = outpost_scene.instance()
		_:
			print("Cannot locate building type " + str(building_type) + " to spawn")
			return
			
	var success = _try_place_building(building, coordinates)
	
	if !success:
		print("Failed to place building at " + str(coordinates))
		return
	
	building.team = team
	building.set_name(building_name)
	add_child(building)
	buildings.push_front(building)


func _despawn_building(building: Building):
	var occupying_tile = _get_tile(building.coordinates)
	occupying_tile.building = null
	buildings.erase(building)
	building.queue_free()


func resolve_turn():
	for building in buildings:
		if !building.under_construction:
			continue
			
		var tile = _get_tile(building.coordinates)
		if !building.construction_requires_worker || tile.has_constructing_worker():
			building.build_time_remaining -= 1
		
		if building.build_time_remaining <= 0:
			building.under_construction = false
		


#Returns an enum flag indicating who died in the battle
func _attack(attacker: Unit, defender: Unit) -> int:
	var distance = _get_path(attacker.coordinates, defender.coordinates).size()
	var is_ranged_attack = attacker.attack_range > 0
	
	if is_ranged_attack && attacker.attack_range >= distance:
		_deal_ranged_damage(attacker, defender)
		if defender.attack_range >= distance:
			_deal_ranged_damage(defender, attacker)
			
	elif !is_ranged_attack && distance == 1:
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


func _deal_melee_damage(from: Unit, to: Unit):
	to.current_health -= from.melee_attack_damage


func _deal_ranged_damage(from: Unit, to: Unit):
	to.current_health -= from.ranged_attack_damage


#Resolves the units based on the battle result enum from the _attack method
func _resolve_attack(attacker: Unit, defender: Unit, battle_result: int):
	if battle_result == BATTLE_RESULT.ATTACKER_DIED:
		_despawn_unit(attacker)
		
	if battle_result == BATTLE_RESULT.DEFENDER_DIED:
		var defender_tile = _get_tile(defender.coordinates)
		_despawn_unit(defender)
		if attacker.attack_range == 0:
			_traverse_to_path(attacker, defender_tile.coordinates.x, defender_tile.coordinates.y)
	
	if battle_result == BATTLE_RESULT.BOTH_DIED:
		_despawn_unit(attacker)
		_despawn_unit(defender)
		
