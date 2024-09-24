extends Node

var savePath = "user://save_file.save"

var collectiblesAmount = {
	"hidden" = 0,
	"puzzle" = 0,
	"challenge" = 0,
	"tiny" = 0
}
var collectiblesObjects = []
var collectiblesList = []

var checkpointsActive = []

@onready var ui: CanvasLayer = $"../UI"

func _on_main_ready() -> void:
	collectiblesObjects = get_tree().get_nodes_in_group("Coins")
	load_data()
	update_collected()

func _physics_process(delta: float) -> void:
	# Temporary save inputs
	if Input.is_action_just_pressed("save"):
		save()
	if Input.is_action_just_pressed("load"):
		load_data()

# -- COLLECTIBLES --
func update_collectible(group):
	match group:
		"Hidden Coins":
			collectiblesAmount["hidden"] += 1
		"Puzzle Coins":
			collectiblesAmount["puzzle"] += 1
		"Challenge Coins":
			collectiblesAmount["challenge"] += 1
		"Tiny Coins":
			collectiblesAmount["tiny"] += 1
	ui.update_collectible_ui(collectiblesAmount["hidden"], collectiblesAmount["puzzle"], collectiblesAmount["challenge"], collectiblesAmount["tiny"])
	update_collected()

func update_collected():
	collectiblesList = []
	for item in collectiblesObjects:
		collectiblesList.append([str(item.get_path()), item.collected])

# -- CHECKPOINT --
func update_checkpoint(checkpointNumber):
	checkpointsActive.append(checkpointNumber)

# -- SAVE AND LOAD --
func save():
	print_rich("[color=white]----------------------------------------------------------------------[/color]")
	print_rich("[color=green][ Saving... ][/color]")
	var saveFile = FileAccess.open(savePath, FileAccess.WRITE)
	# Pack into single variable
	var save = []
	save.append(collectiblesAmount)
	save.append(collectiblesList)
	save.append(checkpointsActive)
	saveFile.store_var(save)
	print_save(save)
	print_rich("[color=green][ Save succesful. ][/color]")
	print_rich("[color=white]----------------------------------------------------------------------[/color]")

func load_data():
	print_rich("[color=white]----------------------------------------------------------------------[/color]")
	print_rich("[color=green][ Loading... ][/color]")
	if FileAccess.file_exists(savePath):
		var saveFile = FileAccess.open(savePath, FileAccess.READ)
		var save = saveFile.get_var()
		
		if save.size() >= 1:
			collectiblesAmount = save[0]
			ui.set_collectible_ui(collectiblesAmount["hidden"], collectiblesAmount["puzzle"], collectiblesAmount["challenge"], collectiblesAmount["tiny"])
		
		if save.size() >= 2:
			collectiblesList = save[1]
			for i in collectiblesList.size():
				get_node(collectiblesList[i][0]).collected = collectiblesList[i][1]
		
		if save.size() >= 3:
			checkpointsActive = save[2]
			for item in checkpointsActive:
				get_node("../Checkpoints/" + str(item) + "/Big").activeCheckpoint = true
				get_node("../Checkpoints/" + str(item) + "/Small").activeCheckpoint = true
		
		print_save(save)
		print_rich("[color=green][ Loading complete. ][/color]")
	else:
		print_rich("[color=red][ Nothing to load. ][/color]")
	print_rich("[color=white]----------------------------------------------------------------------[/color]")

func print_save(save):
	if save.size() >= 1:
		print_rich("  [color=blue]Number of collectibles obtained:[/color]")
		print_rich("    Hidden: [color=yellow]" + str(save[0]["hidden"]) + "[/color], Puzzle: [color=yellow]" + str(save[0]["puzzle"]) + "[/color], Challenge: [color=yellow]" + str(save[0]["challenge"]) + "[/color], Tiny: [color=yellow]" + str(save[0]["tiny"]) + "[/color]")
	if save.size() >= 2:
		print_rich("  [color=blue]Collectibles collected:[/color]")
		for i in save[1].size():
			print_rich("    Path: [color=yellow]" + str(save[1][i][0]) + "[/color], Collected: [color=yellow]" + str(save[1][i][1]) + "[/color]")
	if save.size() >= 3:
		print_rich("  [color=blue]Checkpoints activated:[/color]")
		if save[2].size() != 0:
			for i in save[2].size():
				print_rich("    [color=yellow]" + str(save[2][i]) + "[/color]")
		else:
			print_rich("[color=yellow]    No checkpoints activated.[/color]")
