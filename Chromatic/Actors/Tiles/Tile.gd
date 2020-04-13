extends Actor
class_name Tile

#Fields
var occupant : Unit
var building : Building
var resource_node : ResourceNode
var id: int

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


#Methods
func has_building_under_construction() -> bool:
	return building && building.under_construction


func has_constructing_worker() -> bool:
	return occupant && occupant is Worker && occupant.is_constructing


func is_harvesting() -> bool:
	if !building || building.under_construction:
		return false
	
	if resource_node is Food and building is HuntingCamp:
		return true
	
	return false 


func pop_resources() -> int:
	if !resource_node:
		print("No resource node on this tile")
	
	if resource_node.remaining_charges <= 0:
		print("Resource node has no remaining charges")
	
	resource_node.remaining_charges -= 1
	
	return resource_node.quantity


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


#Directions
func right() -> Vector2:
	return coordinates + Vector2(1, 0)


func bottom_right() -> Vector2:
	if _is_odd(coordinates.y):
		return coordinates + Vector2(0, 1)
	else:
		return coordinates + Vector2(1, 1)


func bottom_left() -> Vector2:
	if _is_odd(coordinates.y):
		return coordinates + Vector2(-1, 1)
	else:
		return coordinates + Vector2(0, 1)


func left() -> Vector2:
	return coordinates + Vector2(-1, 0)


func top_left() -> Vector2:
	if _is_odd(coordinates.y):
		return coordinates + Vector2(-1, -1)
	else:
		return coordinates + Vector2(0, -1)


func top_right() -> Vector2:
	if _is_odd(coordinates.y):
		return coordinates + Vector2(0, -1)
	else:
		return coordinates + Vector2(1, -1)


func get_adjacent_tiles() -> PoolVector2Array:
	var adj_tiles = []
		
	adj_tiles.push_back(top_left())
	adj_tiles.push_back(top_right())
	adj_tiles.push_back(right())
	adj_tiles.push_back(bottom_right())
	adj_tiles.push_back(bottom_left())
	adj_tiles.push_back(left())
	
	return adj_tiles


func _is_odd(row) -> bool:
	return fmod(row, 2) == 1

#End Directions
