extends StaticBody2D

var checkpointReady = false
var standardScreen
var distortedScreen
var plateActive
var otherCheckpoint
var activeCheckpoint
var associatedPlayer

@onready var game_manager: Node = $"/root/Main/GameManager"
@onready var screen: AnimatedSprite2D = $Screen
@onready var distortion_timer: Timer = $Screen/DistortionTimer
@onready var number_1: Sprite2D = $Number1
@onready var number_2: Sprite2D = $Number2
@onready var pressure_plate_sprite: Sprite2D = $PressurePlate/Sprite2D
@onready var pressure_plate_trigger: Area2D = $PressurePlate/PlateTrigger
@onready var animation_player: AnimationPlayer = $PressurePlate/PlateTrigger/AnimationPlayer

func _ready() -> void:
	await get_node("/root/Main").ready
	checkpointReady = true
	
	# Set player
	if get_meta("bigPlayer"):
		standardScreen = "big"
		distortedScreen = "bigDistort"
		associatedPlayer = $"/root/Main/PlayerBig"
	else:
		standardScreen = "small"
		distortedScreen = "smallDistort"
		associatedPlayer = $"/root/Main/PlayerSmall"
	screen.play(standardScreen)
	
	# Set numbers
	var digitOne
	var digitTwo
	digitOne = floorf(float((get_meta("checkpointNumber")) * 0.1)) # 29 (int) -> 29 (float) -> 2.9 -> 2
	digitTwo = get_meta("checkpointNumber") % 10 # 29 -> 29 % 10 = 9 -> 9
	number_1.region_rect = Rect2(81 + digitOne * 12, 87, 12, 22)
	if digitTwo == 0:
		number_2.region_rect = Rect2(201, 87, 12, 22)
	else:
		number_2.region_rect = Rect2(81 + digitTwo * 12, 87, 12, 22)
	
	# Find other checkpoint
	if get_meta("bigPlayer"):
		otherCheckpoint = $"../Small"
	else:
		otherCheckpoint = $"../Big"
	
	# Spawn player
	if game_manager.spawnOnCheckpoint && game_manager.currentCheckpoint == get_meta("checkpointNumber"):
		activeCheckpoint = true
		associatedPlayer.position = position
		animation_player.play("spawn")
		await animation_player.animation_finished
		associatedPlayer.spawned = true
	
	# Start updating screen
	set_and_start_timer()

func _physics_process(delta: float) -> void:
	# Current checkpoint
	if game_manager.currentCheckpoint == get_meta("checkpointNumber"):
		pressure_plate_sprite.region_rect = Rect2(5, 0, 70, 14)
		pressure_plate_trigger.monitoring = false
	
	# Active checkpoint
	elif activeCheckpoint:
		pressure_plate_sprite.region_rect = Rect2(5, 15, 70, 14)
		if pressure_plate_trigger.monitoring == false:
			pressure_plate_trigger.monitoring = true
			animation_player.play("release")
		if plateActive and otherCheckpoint.plateActive:
			if get_meta("bigPlayer"):
				activeCheckpoint = true
				otherCheckpoint.activeCheckpoint = true
				game_manager.update_checkpoint(int(str(get_parent().name)))
				game_manager.currentCheckpoint = get_meta("checkpointNumber")
				game_manager.save()
	
	# Inactive checkpoint
	else:
		pressure_plate_sprite.region_rect = Rect2(5, 30, 70, 14)
		pressure_plate_trigger.monitoring = true
		# Activate checkpoint and make it the current one
		if plateActive and otherCheckpoint.plateActive:
			if get_meta("bigPlayer"):
				activeCheckpoint = true
				otherCheckpoint.activeCheckpoint = true
				game_manager.update_checkpoint(int(str(get_parent().name)))
				game_manager.currentCheckpoint = get_meta("checkpointNumber")
				game_manager.save()

func set_and_start_timer():
	distortion_timer.wait_time = randf_range(0.5, 2)
	distortion_timer.start()

func _on_distortion_timer_timeout() -> void:
	var random = randf()
	screen.stop()
	if random > 0.2:
		screen.play(distortedScreen)
	else:
		screen.play("noSignal")
	await screen.animation_finished
	screen.play(standardScreen)
	set_and_start_timer()

func _on_plate_trigger_body_entered(body: Node2D) -> void:
	if (get_meta("bigPlayer") and body.name == "PlayerBig") or (!get_meta("bigPlayer") and body.name == "PlayerSmall"):
		animation_player.play("push")
		plateActive = true

func _on_plate_trigger_body_exited(body: Node2D) -> void:
	if (get_meta("bigPlayer") and body.name == "PlayerBig") or (!get_meta("bigPlayer") and body.name == "PlayerSmall"):
		if !game_manager.currentCheckpoint == get_meta("checkpointNumber"):
			animation_player.play("release")
		plateActive = false
