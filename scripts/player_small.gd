extends CharacterBody2D


const SPEED = 250.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 0.5
const ACCELERATION = 15.0

var spawned = false
var shock = false
var deathOccured = false

@onready var game_manager: Node = $"/root/Main/GameManager"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer

func _ready() -> void:
	if !game_manager.spawnOnCheckpoint:
		spawned = true

func _input(event):
	if Input.is_action_just_pressed("small_shock") and spawned and !deathOccured and is_on_floor() and !shock:
		shock = true
		velocity.x = 0
		animated_sprite.play("shock")
		animation_player.play("shock")
		await animated_sprite.animation_finished
		shock = false

func _physics_process(delta: float) -> void:
	var jumping = false
	
	if spawned:
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * GRAVITY * delta
		
		# Shocking restricts all movement.
		if not shock:
			# Jump
			if Input.is_action_just_pressed("small_jump") and (is_on_floor() or !coyote_timer.is_stopped()):
				velocity.y = JUMP_VELOCITY
				coyote_timer.stop()
				jumping = true
			
			# Direction
			var direction := Input.get_axis("small_left", "small_right")
			
			# Flip sprite
			if direction > 0:
				animated_sprite.flip_h = false
			if direction < 0:
				animated_sprite.flip_h = true
			
			# Movement Animation
			if is_on_floor():
				if direction == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump")
			
			# Movement
			if direction:
				var speedBefore = velocity.x
				var speedAfter = speedBefore + ACCELERATION * direction
				speedAfter = clamp(speedAfter, -SPEED, SPEED)
				velocity.x = speedAfter
			if is_on_floor():
				# If velocity and direction don't go the same way
				if (velocity.x > 0 and direction < 0) or (velocity.x < 0 and direction > 0) or direction == 0:
					velocity.x = move_toward(velocity.x, 0, SPEED)
			else:
				if not direction:
					velocity.x = move_toward(velocity.x, 0, ACCELERATION)
	
	# Move and slide update
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	# Coyote timer
	if not is_on_floor() and was_on_floor and !jumping:
		coyote_timer.start()

func _on_player_big_death() -> void:
	deathOccured = true
	set_physics_process(false)
