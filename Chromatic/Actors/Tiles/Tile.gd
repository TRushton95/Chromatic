extends Node2D
class_name Tile

#Fields
var occupant : Unit
var building : Building
var resource_node : ResourceNode
var id : int
var coordinates = Vector2(-1, -1)
var claimed_by = -1 setget claimed_by_set
var _team_vision_count_lookup : Dictionary
var fog_of_war : bool setget fog_of_war_set

#Signals
signal tile_hovered
signal tile_unhovered
signal tile_clicked
signal tile_right_clicked
signal tile_right_mouse_released


#Event Handlers
func _on_Hitbox_mouse_entered() -> void:
	get_node("HoverSprite").visible = true;
	emit_signal("tile_hovered", coordinates)


func _on_Hitbox_mouse_exited() -> void:
	get_node("HoverSprite").visible = false;
	emit_signal("tile_unhovered", coordinates)


func _on_Hitbox_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT:
		emit_signal("tile_clicked", coordinates)
	
	if event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_RIGHT:
		emit_signal("tile_right_clicked", coordinates)
	
	if event is InputEventMouseButton && event.is_action_released("right_mouse"):
		emit_signal("tile_right_mouse_released", coordinates)


#Setgetters
func claimed_by_set(value: int) -> void:
	claimed_by = value
	
	if claimed_by == -1:
		get_node("ClaimedMark").visible = false
	else:
		get_node("ClaimedMark").visible = true
		get_node("ClaimedMark/TextureRect").modulate = Lookups.TEAM_COLORS[value]


#TODO this logic needs properly setting (whatever that means)
func fog_of_war_set(value: bool) -> void:
	fog_of_war = value
	
	if value:
		get_node("Sprite").modulate = Color(0.5, 0.5, 0.5)
		if occupant:
			occupant.hide()
		if building:
			building.hide()
		if resource_node:
			resource_node.hide()
			
	else:
		get_node("Sprite").modulate = Color(1, 1, 1)
		if occupant:
			occupant.show()
		if building:
			building.show()
		if resource_node:
			resource_node.show()


#Methods
func _ready() -> void:
	#TEST
	_team_vision_count_lookup = {
		1: 0,
		2: 0
	}


func has_building_under_construction() -> bool:
	return building && building.under_construction


func has_constructing_worker() -> bool:
	return occupant && occupant is Worker && occupant.is_constructing


func is_resource_developed() -> bool:
	if !building || building.under_construction:
		return false
	
	var result = false
	
	if resource_node is Food and building is HuntingCamp:
		result = true
	elif resource_node is Gold and building is MiningCamp:
		result = true
	
	return result


func is_harvesting() -> bool:
	if !resource_node:
		return false
	
	#Claiming undeveloped resources
	if resource_node.basic && claimed_by >= 0:
		return true
	
	if !building || building.under_construction:
		return false
	
	#Claiming developed resources
	if is_resource_developed():
		return true
	
	return false


func pop_resources() -> Array:
	if !resource_node:
		print("No resource node on this tile")
		return []
	
	if resource_node.remaining_charges <= 0:
		print("Resource node has no remaining charges")
		return []
	
	var harvest = 1
	if is_resource_developed():
		if resource_node.remaining_charges < resource_node.resource_yield:
			harvest = resource_node.remaining_charges
		else:
			harvest = resource_node.resource_yield
	
	resource_node.remaining_charges -= harvest
	
	return [resource_node.resource_type, harvest]


func add_team_vision_count(team: int, count: int):
	if !_team_vision_count_lookup.has(team):
		return
	
	_team_vision_count_lookup[team] += count
	
	var fog = _team_vision_count_lookup[team] <= 0
	fog_of_war_set(fog)


func set_fog_of_war_for_team(team: int) -> void:
	if !_team_vision_count_lookup.has(team):
		return
	
	fog_of_war_set(!_team_vision_count_lookup[team])


func has_hostile_unit(current_team: int) -> bool:
	return occupant && occupant.team != current_team


func has_hostile_building(current_team: int) -> bool:
	return building && building.team != current_team


func has_hostile_player_entity(current_team: int) -> bool:
	return has_hostile_unit(current_team) || has_hostile_building(current_team)


func has_friendly_unit(current_team: int) -> bool:
	return occupant && occupant.team == current_team


func has_friendly_building(current_team: int) -> bool:
	return building && building.team == current_team


func get_adjacent_tiles() -> PoolVector2Array:
	var adj_tiles = []
		
	adj_tiles.push_back(_top_left(coordinates))
	adj_tiles.push_back(_top_right(coordinates))
	adj_tiles.push_back(_right(coordinates))
	adj_tiles.push_back(_bottom_right(coordinates))
	adj_tiles.push_back(_bottom_left(coordinates))
	adj_tiles.push_back(_left(coordinates))
	
	return adj_tiles


func show_red_filter():
	get_node("RedFilter").visible = true


func hide_red_filter():
	get_node("RedFilter").visible = false


func show_white_filter():
	get_node("WhiteFilter").visible = true


func hide_white_filter():
	get_node("WhiteFilter").visible = false


func show_yellow_filter():
	get_node("YellowFilter").visible = true


func hide_yellow_filter():
	get_node("YellowFilter").visible = false


#Static Methods
static func get_tiles_in_radius(center_tile: Vector2, radius = 1) -> PoolVector2Array:
	var adj_tiles = [center_tile]
	var current_tile = center_tile
	var distance_to_corner = 1
	
	for i in range(0, radius):
		current_tile = _bottom_left(current_tile)
		
		for j in range(0, distance_to_corner):
			adj_tiles.push_back(current_tile)
			current_tile = _top_left(current_tile)
		for j in range(0, distance_to_corner):
			adj_tiles.push_back(current_tile)
			current_tile = _top_right(current_tile)
		for j in range(0, distance_to_corner):
			adj_tiles.push_back(current_tile)
			current_tile = _right(current_tile)
		for j in range(0, distance_to_corner):
			adj_tiles.push_back(current_tile)
			current_tile = _bottom_right(current_tile)
		for j in range(0, distance_to_corner):
			adj_tiles.push_back(current_tile)
			current_tile = _bottom_left(current_tile)
		for j in range(0, distance_to_corner):
			adj_tiles.push_back(current_tile)
			current_tile = _left(current_tile)
		
		distance_to_corner += 1
	
	return adj_tiles


static func _right(coords: Vector2) -> Vector2:
	return coords + Vector2(1, 0)


static func _bottom_right(coords: Vector2) -> Vector2:
	if _is_odd(coords.y):
		return coords + Vector2(0, 1)
	else:
		return coords + Vector2(1, 1)


static func _bottom_left(coords: Vector2) -> Vector2:
	if _is_odd(coords.y):
		return coords + Vector2(-1, 1)
	else:
		return coords + Vector2(0, 1)


static func _left(coords: Vector2) -> Vector2:
	return coords + Vector2(-1, 0)


static func _top_left(coords: Vector2) -> Vector2:
	if _is_odd(coords.y):
		return coords + Vector2(-1, -1)
	else:
		return coords + Vector2(0, -1)


static func _top_right(coords: Vector2) -> Vector2:
	if _is_odd(coords.y):
		return coords + Vector2(0, -1)
	else:
		return coords + Vector2(1, -1)


static func _is_odd(row) -> bool:
	return abs(fmod(row, 2)) == 1
