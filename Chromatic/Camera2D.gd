extends Camera2D

#Fields
const SCROLL_SPEED = 10
const MAX_ZOOM = Vector2(1.5, 1.5)
const MIN_ZOOM = Vector2.ONE


#Methods
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("camera_up"):
		velocity += Vector2(0, -1)
	if Input.is_action_pressed("camera_left"):
		velocity += Vector2(-1, 0)
	if Input.is_action_pressed("camera_down"):
		velocity += Vector2(0, 1)
	if Input.is_action_pressed("camera_right"):
		velocity += Vector2(1, 0)
	
	velocity = velocity.normalized() * SCROLL_SPEED
	
	position += velocity


func _input(event: InputEvent) -> void:
	var zoom_scale = 0
	
	if event.is_action("camera_zoom_in"):
		zoom_scale = -0.1
	elif event.is_action("camera_zoom_out"):
		zoom_scale = 0.1
	
	zoom += Vector2.ONE * zoom_scale
	
	if zoom < MIN_ZOOM:
		zoom = MIN_ZOOM
	
	if zoom > MAX_ZOOM:
		zoom = MAX_ZOOM
