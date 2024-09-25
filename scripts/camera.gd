extends Node2D

const ZOOM_MULTIPLIER = 0.6
const MAXIMUM_ZOOM = 1
var applied_zoom = 1

@onready var player_big: CharacterBody2D = $"../PlayerBig"
@onready var player_small: CharacterBody2D = $"../PlayerSmall"
@onready var camera: Camera2D = $Camera

func _ready() -> void:
	await get_tree().process_frame
	setCamera(false)
	await get_tree().process_frame
	camera.position_smoothing_enabled = true

func _process(delta: float) -> void:
	setCamera(true)

func setCamera(smoothZoom):
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
	var zoom_x = ((get_viewport().size.x * 0.5) / player_x_difference) * ZOOM_MULTIPLIER
	var zoom_y = ((get_viewport().size.x * 0.5) / player_y_difference) * ZOOM_MULTIPLIER * 0.5
	
	# Pick biggest zoom
	var final_zoom
	if zoom_x < zoom_y:
		final_zoom = zoom_x
	else:
		final_zoom = zoom_y
	
	# Set maximum
	if final_zoom > MAXIMUM_ZOOM:
		final_zoom = MAXIMUM_ZOOM
	
	# Smoothing
	if smoothZoom:
		if applied_zoom > final_zoom * 1.2:
			applied_zoom -= 0.001
		elif applied_zoom < final_zoom:
			applied_zoom += 0.0005
	else:
		applied_zoom = final_zoom
	
	# Set minimum
	var min_zoom_x = float(get_viewport().size.x * 0.5) / float(camera.limit_right - camera.limit_left)
	var min_zoom_y = float(get_viewport().size.y * 0.5) / float(camera.limit_bottom - camera.limit_top)
	if min_zoom_x > min_zoom_y and applied_zoom < min_zoom_x:
		applied_zoom = min_zoom_x
	elif min_zoom_x < min_zoom_y and applied_zoom < min_zoom_y:
		applied_zoom = min_zoom_y
	
	camera.zoom = Vector2(applied_zoom, applied_zoom)
