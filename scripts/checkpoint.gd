extends StaticBody2D

var standard
var distorted
var activePlate
var otherCheckpoint
var activeCheckpoint

@onready var game_manager: Node = $"/root/Main/GameManager"
@onready var screen: AnimatedSprite2D = $Screen
@onready var distortion_timer: Timer = $Screen/DistortionTimer
@onready var number_1: Sprite2D = $Number1
@onready var number_2: Sprite2D = $Number2
@onready var pressure_plate_sprite: Sprite2D = $PressurePlate/Sprite2D
@onready var animation_player: AnimationPlayer = $PressurePlate/PlateTrigger/AnimationPlayer

func _ready() -> void:
	# Set screen
	if get_meta("bigPlayer"):
		standard = "big"
		distorted = "bigDistort"
	else:
		standard = "small"
		distorted = "smallDistort"
	screen.play(standard)
	
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
	
	# Start updating screen
	set_and_start_timer()

func _physics_process(delta: float) -> void:
	# Find other checkpoint
	if get_meta("bigPlayer"):
		otherCheckpoint = $"../Small"
	else:
		otherCheckpoint = $"../Big"
	
	# Check activeness
	if activeCheckpoint:
		pressure_plate_sprite.region_rect = Rect2(5, 0, 70, 14)
	else:
		if activePlate:
			if otherCheckpoint.activePlate:
				# Both active
				activeCheckpoint = true
				pressure_plate_sprite.region_rect = Rect2(5, 0, 70, 14)
				if get_meta("bigPlayer"):
					game_manager.update_checkpoint(get_parent().name)
			else:
				# Active
				pressure_plate_sprite.region_rect = Rect2(5, 15, 70, 14)
		else:
			# Not active
			pressure_plate_sprite.region_rect = Rect2(5, 30, 70, 14)

func set_and_start_timer():
	distortion_timer.wait_time = randf_range(0.5, 2)
	distortion_timer.start()

func _on_distortion_timer_timeout() -> void:
	var random = randf()
	screen.stop()
	if random > 0.2:
		screen.play(distorted)
	else:
		screen.play("noSignal")
	await screen.animation_finished
	screen.play(standard)
	set_and_start_timer()

func _on_plate_trigger_body_entered(body: Node2D) -> void:
	if (get_meta("bigPlayer") and body.name == "PlayerBig") or (!get_meta("bigPlayer") and body.name == "PlayerSmall"):
		animation_player.play("push")
		activePlate = true

func _on_plate_trigger_body_exited(body: Node2D) -> void:
	if (get_meta("bigPlayer") and body.name == "PlayerBig") or (!get_meta("bigPlayer") and body.name == "PlayerSmall"):
		animation_player.play("release")
		activePlate = false
