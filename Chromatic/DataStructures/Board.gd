extends Node
class_name Board

#Tile Scenes
var tile_scene := preload("res://Actors/Tiles/Tile.tscn")

#Constants
const TILE_DIAMETER := 64

#Fields
var tile_lookup := {}
var tile_path_highlight := []
var astar := AStar2D.new()
var last_discovered_tiles_for_team := {}


#Methods
func generate_test_map(columns: int, rows: int) -> void:
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
			
			tile_lookup[_tile_name(Vector2(x, y))] = tile
			add_child(tile)
			
			id += 1
	
	for tile in get_all_tiles():
		_connect_to_adjacent_tiles(tile)


#region Tiles

func _tile_name(coordinates: Vector2) -> String:
	return "tile_" + str(coordinates.x) + "," + str(coordinates.y)


func _connect_to_adjacent_tiles(tile):
	for adj_tile_coords in tile.get_adjacent_tiles():
		var adj_tile_key = _tile_name(adj_tile_coords)
		
		if tile_lookup.has(adj_tile_key):
			var adj_tile = tile_lookup[adj_tile_key]
			astar.connect_points(tile.id, adj_tile.id)


func get_tile(coordinates: Vector2) -> Tile:
	var result : Tile
	
	var tile_name = _tile_name(coordinates)
	if !has_node(tile_name):
		print ("No tile at " + str(coordinates))
	
	result = get_node(tile_name)
	
	return result


func get_tiles(tile_set_coordinates: PoolVector2Array) -> Array:
	var result = []
	
	for tile_coordinates in tile_set_coordinates:
		var tile = get_tile(tile_coordinates)
		if tile:
			result.push_back(tile)
	
	return result


func get_all_tiles() -> Array:
	var result = []
	
	for tile_key in tile_lookup:
		result.push_back(tile_lookup[tile_key])
	
	return result

#endregion

#region Entity

func try_place_unit(unit: Unit, dest_coordinates: Vector2) -> bool:
	var destination_tile = get_tile(dest_coordinates)
	var source_tile = get_tile(unit.coordinates)
	
	if !destination_tile || destination_tile.occupant:
		return false
	
	destination_tile.occupant = unit
	unit.coordinates = destination_tile.coordinates
	unit.position = destination_tile.position
	update_entity_vision_counters(unit, source_tile)
	
	if source_tile:
		source_tile.occupant = null
	
	return true


func try_place_building(building, dest_coordinates: Vector2) -> bool:
	var source_tile = get_tile(building.coordinates)
	if source_tile:
		print("Building already placed and cannot be moved!")
		return false
	
	var destination_tile = get_tile(dest_coordinates)
	
	if !destination_tile || destination_tile.building:
		print("There is already a building there")
		return false
	
	destination_tile.building = building
	building.coordinates = destination_tile.coordinates
	building.position = destination_tile.position
	update_entity_vision_counters(building, source_tile)
	
	return true


func try_place_resource_node(resource_node : ResourceNode, dest_coordinates: Vector2) -> bool:
	var result = false
	
	var source_tile = get_tile(resource_node.coordinates)
	if source_tile:
		print("Resource node already placed and cannot be moved!")
		return false
	
	var destination_tile = get_tile(dest_coordinates)
	
	if destination_tile && !destination_tile.resource_node:
		destination_tile.resource_node = resource_node
		resource_node.coordinates = destination_tile.coordinates
		resource_node.position = destination_tile.position
		
		result = true
	
	return result

#endregion

#region Highlighting

func highlight_tile_yellow(coordinates : Vector2):
		get_tile(coordinates).show_yellow_filter()


func remove_highlight_tile_yellow(coordinates : Vector2):
		get_tile(coordinates).hide_yellow_filter()

#endregion

#region Pathfinding

func get_movement_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var source_tile = get_tile(from)
	var destination_tile = get_tile(to)
	
	var result = astar.get_point_path(source_tile.id, destination_tile.id)
	result.remove(0) #Remove source tile frrm path
	
	return result


#Combat path is as the crow flies -
#All tiles are temporarily enabled to find the most direct path and then the previously
#disabled tiles are re-disabled
func get_combat_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	var disabled_tiles = []
	
	for tile in get_all_tiles():
		if astar.is_point_disabled(tile.id):
			disabled_tiles.push_back(tile)
			astar.set_point_disabled(tile.id, false)
	
	var result = get_movement_path(from, to)
	
	for disabled_tile in disabled_tiles:
		astar.set_point_disabled(disabled_tile.id, true)
	
	return result


func map_path(from: Vector2, to: Vector2) -> void:
	var point_path = get_movement_path(from, to)
	for point in point_path:
		var tile = get_tile(point)
		tile.show_white_filter()
		tile_path_highlight.push_back(tile)


func clear_tile_path() -> void:
	for tile in tile_path_highlight:
		tile.hide_white_filter()
	
	tile_path_highlight.clear()


func set_astar_routing(team) -> void:
	for tile in get_all_tiles():
		if !tile.fog_of_war && tile.occupant && tile.occupant.team != team:
			astar.set_point_disabled(tile.id, true)
		else:
			astar.set_point_disabled(tile.id, false)

#endregion

#region Claiming

func try_claim_tile(coordinates: Vector2, team: int) -> bool:
	var result = false
	
	var tile = get_tile(coordinates)
	if tile.claimed_by == -1:
		tile.claimed_by = team
		result = true
	
	return result

#endregion

#region Fog Of War

func refresh_fog_of_war_for_team(team: int) -> void:
	for tile in get_all_tiles():
		if team == -1:
			tile.fog_of_war = false
		else:
			tile.display_fog_of_war_for_team(team)


func clear_player_entity_vision(entity: PlayerEntity) -> void:
	var visible_tile_coords = Tile.get_tiles_in_radius(entity.coordinates, entity.current_vision_range)
	var visible_tiles = get_tiles(visible_tile_coords)
	for tile in visible_tiles:
		tile.add_team_vision_count(entity.team, -1)


func update_entity_vision_counters(entity: PlayerEntity, prev_tile: Tile = null):
	if !entity:
		return
	
	#Decrement old tile vision count
	var old_tiles = []
	if prev_tile:
		var old_tile_coords = Tile.get_tiles_in_radius(prev_tile.coordinates, entity.current_vision_range)
		for old_tile in get_tiles(old_tile_coords):
			old_tile.add_team_vision_count(entity.team, -1)
	
	#Increment new tile vision count
	var vision_range = entity.current_vision_range
	if entity is Building && entity.under_construction:
		vision_range = 0
	
	var visible_tile_coords = Tile.get_tiles_in_radius(entity.coordinates, vision_range)
	var visible_tiles = get_tiles(visible_tile_coords)
	var discovered_tiles = []
	for tile in visible_tiles: 
		#Collect newly discovered tiles to push info to player
		if !old_tiles.has(tile) && tile.fog_of_war:
			discovered_tiles.push_back(tile)
			
		tile.add_team_vision_count(entity.team, 1)
	
	last_discovered_tiles_for_team[entity.team] = discovered_tiles


func get_last_discovered_tiles_for_team(team: int) -> Array:
	var result = []
	
	if last_discovered_tiles_for_team.has(team):
		result = last_discovered_tiles_for_team[team]
	
	return result

#endregion
