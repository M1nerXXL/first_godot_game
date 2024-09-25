extends StaticBody2D

@onready var game_manager: Node = $"/root/Main/GameManager"
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sparkles: GPUParticles2D = $Sparkles

var collected = false
var wasCollected

func _physics_process(delta: float) -> void:
	if !wasCollected and collected:
		animated_sprite.play("pickedUp")
		sparkles.emitting = false
	elif wasCollected and !collected:
		if animation_player.is_playing():
			animation_player.stop()
		animated_sprite.play("default")
		sparkles.emitting = true
	wasCollected = collected

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !collected:
		collected = true
		animation_player.play("pickUp")
		for group in get_groups():
			if group == "Hidden Coins" or group == "Puzzle Coins" or group == "Challenge Coins" or group == "Tiny Coins":
				game_manager.update_collectible(group)
	elif !animation_player.is_playing():
		animation_player.play("touchPickedUp")
