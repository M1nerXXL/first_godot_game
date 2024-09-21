extends Area2D

@onready var death_particles: GPUParticles2D = $DeathParticles
@onready var reset_timer: Timer = $ResetTimer

func _on_body_entered(body: Node2D) -> void:
	reset_timer.start()
	death_particles.global_position = body.global_position
	death_particles.emitting = true
	body.queue_free()

func _on_reset_timer_timeout() -> void:
	get_tree().reload_current_scene()
