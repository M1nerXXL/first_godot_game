extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -500.0
const GRAVITY = 1
var crouch = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Crouching
func _input(event):
	if Input.is_action_just_pressed("big_crouch") and is_on_floor():
		crouch = true
		animated_sprite.play("crouching")
		animation_player.play("crouch")
		print("1")
	if Input.is_action_just_released("big_crouch") and is_on_floor():
		if crouch:
			animated_sprite.play("stand")
			animation_player.play("RESET")
			await animated_sprite.animation_finished
			print("2")
			crouch = false

func _physics_process(delta: float) -> void:
	# Crouching restricts all movement.
	if not crouch:
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * GRAVITY * delta

		# Jump
		if Input.is_action_just_pressed("big_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

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
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
