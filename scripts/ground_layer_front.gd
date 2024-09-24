extends TileMapLayer

@onready var animation_player: AnimationPlayer = $Area2D/AnimationPlayer

func _on_area_2d_area_entered(area: Area2D) -> void:
	animation_player.play("reveal")

func _on_area_2d_area_exited(area: Area2D) -> void:
	animation_player.play("hide")
