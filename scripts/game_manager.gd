extends Node

signal load_complete

var savePath = "user://save_file.save"

var collectiblesAmount = {
	"hidden" = 0,
	"puzzle" = 0,
	"challenge" = 0,
	"tiny" = 0
}
var collectiblesObjects = []
var collectiblesList = []

@onready var signal_timer: Timer = $SignalTimer
@onready var ui: CanvasLayer = $"../UI"

func _on_main_ready() -> void:
	collectiblesObjects = get_tree().get_nodes_in_group("Coins")
	load_data()
	update_collected()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		save()
	if Input.is_action_just_pressed("load"):
		load_data()

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

func save():
	print_rich("[color=white]----------------------------------------------------------------------[/color]")
	print_rich("[color=green][ Saving... ][/color]")
	var saveFile = FileAccess.open(savePath, FileAccess.WRITE)
	# Pack into single variable
	var save = []
	save.append(collectiblesAmount)
	save.append(collectiblesList)
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
		
		collectiblesAmount = save[0] # collectiblesAmount
		
		# collectiblesAmount loading
		ui.set_collectible_ui(collectiblesAmount["hidden"], collectiblesAmount["puzzle"], collectiblesAmount["challenge"], collectiblesAmount["tiny"])
		
		collectiblesList = save[1] # collectiblesList
		
		# collectiblesCollected loading
		for i in collectiblesList.size():
			get_node(collectiblesList[i][0]).collected = collectiblesList[i][1]
			
		print_save(save)
		load_complete.emit()
		print_rich("[color=green][ Loading complete. ][/color]")
	else:
		print_rich("[color=red][ Nothing to load. ][/color]")
	print_rich("[color=white]----------------------------------------------------------------------[/color]")

func print_save(save):
	print_rich("  [color=blue]Number of collectibles obtained:[/color]")
	print_rich("    Hidden: [color=yellow]" + str(save[0]["hidden"]) + "[/color], Puzzle: [color=yellow]" + str(save[0]["puzzle"]) + "[/color], Challenge: [color=yellow]" + str(save[0]["challenge"]) + "[/color], Tiny: [color=yellow]" + str(save[0]["tiny"]) + "[/color]")
	print_rich("  [color=blue]Collectibles collected:[/color]")
	for i in save[1].size():
		print_rich("    Path: [color=yellow]" + str(save[1][i][0]) + "[/color], Collected: [color=yellow]" + str(save[1][i][1]) + "[/color]")
