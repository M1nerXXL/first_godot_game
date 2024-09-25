extends CharacterBody2D

signal death

const SPEED = 100.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 1
const ACCELERATION = 10.0

var spawned = false
var state = "stand" # stand, standToCrouch, crouch, crouchToStand
var crouchRestrictions = false
var deathOccured = false

@onready var game_manager: Node = $"/root/Main/GameManager"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var top: RayCast2D = $Top
@onready var bottom: RayCast2D = $Bottom
@onready var left: RayCast2D = $Left
@onready var right: RayCast2D = $Right
@onready var death_particles: GPUParticles2D = $DeathParticles
@onready var reset_timer: Timer = $ResetTimer

func _ready() -> void:
	if !game_manager.spawnOnCheckpoint:
		spawned = true

func _physics_process(delta: float) -> void:
	var jumping = false
	
	if spawned:
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * GRAVITY * delta
		
		# Crouching
		if !deathOccured and is_on_floor():
			if Input.is_action_pressed("big_crouch"):
				if state == "stand":
					crouchRestrictions = true
					state = "standToCrouch"
					velocity.x = 0
					animated_sprite.play("crouching")
					animation_player.play("crouch")
					await animation_player.animation_finished
					state = "crouch"
			else:
				if state == "crouch":
					state == "crouchToStand"
					animated_sprite.play("stand")
					animation_player.play("RESET")
					await animated_sprite.animation_finished
					state = "stand"
					crouchRestrictions = false
		
		# Crouching restricts all movement.
		if !crouchRestrictions:
			# Jump
			if Input.is_action_just_pressed("big_jump") and (is_on_floor() or !coyote_timer.is_stopped()):
				velocity.y = JUMP_VELOCITY
				coyote_timer.stop()
				jumping = true
			
			# Direction
			var direction := Input.get_axis("big_left", "big_right")
			
			# Flip sprite
			if direction > 0:
				animated_sprite.flip_h = false
			if direction < 0:
				animated_sprite.flip_h = true
			
			# Animation
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
	
	# Crushed
	if (top.is_colliding() and bottom.is_colliding()) or (left.is_colliding() and right.is_colliding()):
		animated_sprite.visible = false
		death_particles.emitting = true
		deathOccured = true
		reset_timer.start()
		set_physics_process(false)
		death.emit()

func _on_reset_timer_timeout() -> void:
	get_tree().reload_current_scene()
