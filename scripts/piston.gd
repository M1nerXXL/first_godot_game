extends Node2D

@onready var piston: AnimatableBody2D = $Piston
@onready var animation_player: AnimationPlayer = $Piston/AnimationPlayer

func _ready():
	animation_player.play("RESET")

func _on_trigger_extend_body_entered(body: Node2D) -> void:
	if animation_player.is_playing():
		await animation_player.animation_finished
	animation_player.play("extend")

func _on_trigger_body_exited(body: Node2D) -> void:
	if animation_player.is_playing():
		await animation_player.animation_finished
	animation_player.play("RESET")
