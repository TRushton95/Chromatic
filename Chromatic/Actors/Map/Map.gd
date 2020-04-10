extends Node
class_name Map

#Scenes
var tile_scene = preload("res://Actors/Tiles/Tile.tscn")

#Unit Scenes
var settler_scene = preload("res://Actors/Units/Settler/Settler.tscn")
var warrior_scene = preload("res://Actors/Units/Warrior/Warrior.tscn")

#Building Scenes
var settlement_scene = preload("res://Actors/Buildings/Settlement/Settlement.tscn")

#Constants
const TILE_DIAMETER = 64

#Enums
enum UNIT_TYPE { SETTLER, WARRIOR }
enum BATTLE_RESULT { NONE_DIED, ATTACKER_DIED, DEFENDER_DIED, BOTH_DIED }

#Fields
var rows = 8
var columns = 10
var selected_unit : Unit
var tile_lookup = {}
var astar = AStar2D.new()
var tile_path_highlight = []
var previous_hovered_tile : Tile

#Signals
signal unit_selected
signal unit_deselected


#Event Handlers
func _on_tile_clicked(coordinates : Vector2) -> void:
	var tile = _get_tile(coordinates.x, coordinates.y)
	
	if !tile:
		return
	
	if tile.occupant:
		if selected_unit:
			var selected_unit_tile = _get_tile(selected_unit.coordinates.x, selected_unit.coordinates.y)
			
			selected_unit_tile.hide_yellow_filter()
			selected_unit.hide_health_bar()
		
		selected_unit = tile.occupant
		tile.show_yellow_filter()
		emit_signal("unit_selected", tile.occupant)


func _on_tile_hovered(coordinates: Vector2) -> void:
	var hovered_tile = _get_tile(coordinates.x, coordinates.y)
	if hovered_tile && hovered_tile.occupant != null:
		hovered_tile.occupant.show_health_bar()
		
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		_clear_tile_path()
		if selected_unit:
			_map_path(selected_unit.coordinates, coordinates)


func _on_tile_unhovered(coordinates: Vector2) -> void:
	var hovered_tile = _get_tile(coordinates.x, coordinates.y)
	if hovered_tile && hovered_tile.occupant  && hovered_tile.occupant != selected_unit:
		hovered_tile.occupant.hide_health_bar()


func _on_tile_right_clicked(coordinates: Vector2) -> void:
	if selected_unit:
		_map_path(selected_unit.coordinates, coordinates)


func _on_tile_right_mouse_released(coordinates: Vector2) -> void:
	if !selected_unit:
		return
	
	var target_tile = _get_tile(coordinates.x, coordinates.y)
	
	if !target_tile.occupant:
		_traverse_to_path(selected_unit, coordinates.x, coordinates.y)
	else:
		if selected_unit.team != target_tile.occupant.team:
			var battle_result = _attack(selected_unit, target_tile.occupant)
			_resolve_attack(selected_unit, target_tile.occupant, battle_result)
			


func _on_AbilityButton_pressed() -> void:
	var tile = _get_tile(selected_unit.coordinates.x, selected_unit.coordinates.y)
	
	if tile.building:
		print("Cannot build on tile " + str(tile.coordinates) + ". A building already exists there!")
		return
	
	var settlement = settlement_scene.instance()
	tile.building = settlement
	settlement.coordinates = selected_unit.coordinates
	settlement.position = selected_unit.position
	add_child(settlement)


#Methods
func _ready() -> void:
	_generate_test_map()
	_spawn_unit(UNIT_TYPE.SETTLER, "Settler", Vector2(0,0), 1)
	_spawn_unit(UNIT_TYPE.WARRIOR, "Warrior", Vector2(5,5), 2)


func _process(_delta: float) -> void:
	if Input.is_action_just_released("right_mouse"):
		_clear_tile_path()
		
	if Input.is_action_just_pressed("cancel") && selected_unit:
		_get_tile(selected_unit.coordinates.x, selected_unit.coordinates.y).hide_yellow_filter()
		selected_unit = null
		emit_signal("unit_deselected")
	
	if selected_unit && Input.is_action_just_pressed("test_build_action"):
		var settlement = settlement_scene.instance()
		settlement.coordinates = selected_unit.coordinates
		settlement.position = selected_unit.position
		add_child(settlement)


func _generate_test_map():
	var id = 0
	
	for y in rows:
		for x in columns:
			var tile = tile_scene.instance()
			tile.set_name(_tile_name(x, y))
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
			tile_lookup[_tile_name(x, y)] = tile
			add_child(tile)
			
			id += 1
	
	for tile_key in tile_lookup:
		_connect_to_adjacent_tiles(tile_lookup[tile_key])
		


func _connect_to_adjacent_tiles(tile):
	for adj_tile_coords in tile.get_adjacent_tiles():
		var adj_tile_key = _tile_name(adj_tile_coords.x, adj_tile_coords.y)
		
		if (tile_lookup.has(adj_tile_key)):
			var adj_tile = tile_lookup[adj_tile_key]
			astar.connect_points(tile.id, adj_tile.id)

func _tile_name(x, y) -> String:
	return "tile_" + str(x) + "," + str(y)


func _get_tile(x, y) -> Node:
	return get_node(_tile_name(x, y))


func _try_place_building(building, x, y) -> bool:
	var result = false
	var tile = _get_tile(x, y)
	
	if tile && !tile.building:
		tile.building = building
		result = true
	
	return result
	


func _try_place_unit(unit, x, y) -> bool:
	var result = false
	var source_tile = _get_tile(unit.coordinates.x, unit.coordinates.y)
	var destination_tile = get_node(_tile_name(x, y))
	
	if destination_tile && !destination_tile.occupant:
		destination_tile.occupant = unit
		unit.coordinates = destination_tile.coordinates
		unit.position = destination_tile.position
		
		if source_tile:
			source_tile.occupant = null
			
		result = true
	
	return result


func _get_path(from, to) -> PoolVector2Array:
	var source_tile = get_node(_tile_name(from.x, from.y))
	var destination_tile = get_node(_tile_name(to.x, to.y))
	
	var result = astar.get_point_path(source_tile.id, destination_tile.id)
	result.remove(0) #Path includes source_tile
	
	return result


func _traverse_to_path(unit, x, y) -> void:
	_get_tile(unit.coordinates.x, unit.coordinates.y).hide_yellow_filter()
	var point_path = _get_path(unit.coordinates, Vector2(x, y))
	
	for point in point_path:
		_try_place_unit(unit, point.x, point.y)
	
	_get_tile(unit.coordinates.x, unit.coordinates.y).show_yellow_filter()
	_clear_tile_path()


func _clear_tile_path() -> void:
	for tile in tile_path_highlight:
		tile.hide_white_filter()
	
	tile_path_highlight.clear()


func _map_path(from: Vector2, to: Vector2) -> void:
	var point_path = _get_path(from, to)
	for point in point_path:
		var tile = _get_tile(point.x, point.y)
		tile.show_white_filter()
		tile_path_highlight.push_back(tile)
		
func _spawn_unit(unit_type: int, unit_name: String, coordinates: Vector2, team: int) -> void:
	var unit
	
	match unit_type:
		UNIT_TYPE.SETTLER:
			unit = settler_scene.instance()
			unit.connect("build_settlement", self, "_on_build_settlement")
		UNIT_TYPE.WARRIOR:
			unit = warrior_scene.instance()
		_:
			print("Cannot locate unit type " + str(unit_type) + " to spawn")
			return
	
	var success = _try_place_unit(unit, coordinates.x, coordinates.y)
	
	if !success:
		print("Failed to place unit at " + str(coordinates))
		return
	
	unit.team = team
	unit.set_name(unit_name)
	add_child(unit)
	

func _despawn_unit(unit: Unit) -> void:
	var occupying_tile = _get_tile(unit.coordinates.x, unit.coordinates.y)
	occupying_tile.occupant = null
	unit.queue_free()


#Returns an enum flag indicating who died in the battle
func _attack(attacker: Unit, defender: Unit) -> int:
	defender.current_health -= attacker.attack_damage
	attacker.current_health -= defender.attack_damage
	
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


#Resolves the units based on the battle result enum from the _attack method
func _resolve_attack(attacker: Unit, defender: Unit, battle_result: int):
	if battle_result == BATTLE_RESULT.ATTACKER_DIED:
		_despawn_unit(attacker)
		
	if battle_result == BATTLE_RESULT.DEFENDER_DIED:
		var defender_tile = _get_tile(defender.coordinates.x, defender.coordinates.y)
		_despawn_unit(defender)
		_traverse_to_path(attacker, defender_tile.coordinates.x, defender_tile.coordinates.y)
	
	if battle_result == BATTLE_RESULT.BOTH_DIED:
		_despawn_unit(attacker)
		_despawn_unit(defender)
		
