extends Camera2D

const ZOOM_MULTIPLIER = 0.5
const MAXIMUM_ZOOM = 1

@onready var player_big: CharacterBody2D = $"../PlayerBig"
@onready var player_small: CharacterBody2D = $"../PlayerSmall"

func _process(delta: float) -> void:
	var player_x_difference = player_big.position.x - player_small.position.x
	var player_y_difference = player_big.position.y - player_small.position.y
	
	# Position
	position.x = player_small.position.x + player_x_difference * 0.5
	position.y = player_small.position.y + player_y_difference * 0.5

	# Zoom
	
	# Set positive
	if player_x_difference < 0:
		player_x_difference *= -1
	if player_y_difference < 0:
		player_y_difference *= -1
	
	# Calculate
	var zoom_x = (960 / player_x_difference) * ZOOM_MULTIPLIER
	var zoom_y = (960 / player_y_difference) * ZOOM_MULTIPLIER
	
	# Set minimum
	var min_zoom_x = float(960) / float(limit_right - limit_left)
	var min_zoom_y = float(960) / float(limit_bottom - limit_top)
	
	if zoom_x < min_zoom_x:
		zoom_x = min_zoom_x
	if zoom_y < min_zoom_y:
		zoom_y = min_zoom_y
	
	# Pick biggest zoom
	var applied_zoom
	if zoom_x < zoom_y:
		applied_zoom = zoom_x
	else:
		applied_zoom = zoom_y
	
	# Set maximum
	if applied_zoom > MAXIMUM_ZOOM:
		applied_zoom = MAXIMUM_ZOOM
	
	# Apply
	zoom = Vector2(applied_zoom, applied_zoom)
