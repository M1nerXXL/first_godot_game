extends CanvasLayer

var hudCollectibles = {
	"hidden": 0,
	"puzzle": 0,
	"challenge": 0,
	"tiny": 0
}

@onready var animation_player: AnimationPlayer = $Control/Coins/AnimationPlayer
@onready var display_timer: Timer = $Control/Coins/DisplayTimer
@onready var updateTimer: Timer = $Control/Coins/UpdateTimer
@onready var hiddenAmount: Label = $Control/Coins/Hidden/Amount
@onready var puzzleAmount: Label = $Control/Coins/Puzzle/Amount
@onready var challengeAmount: Label = $Control/Coins/Challenge/Amount
@onready var tinyAmount: Label = $Control/Coins/Tiny/Amount

# Update collectibles in HUD
func update_collectible_ui(hidden, puzzle, challenge, tiny):
	hudCollectibles = {
	"hidden": hidden,
	"puzzle": puzzle,
	"challenge": challenge,
	"tiny": tiny
	}
	updateTimer.start()
	if(display_timer.is_stopped()):
		animation_player.play("show")
	else:
		display_timer.stop()
	display_timer.start()

# End of display timer
func _on_display_timer_timeout() -> void:
	animation_player.play("hide")

# End of update timer
func _on_timer_timeout() -> void:
	set_collectible_ui(hudCollectibles["hidden"], hudCollectibles["puzzle"], hudCollectibles["challenge"], hudCollectibles["tiny"])

# Sets the UI
# Called through update function or directly
func set_collectible_ui(hidden, puzzle, challenge, tiny):
	hiddenAmount.text = str(hidden)
	puzzleAmount.text = str(puzzle)
	challengeAmount.text = str(challenge)
	tinyAmount.text = str(tiny)
