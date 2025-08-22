extends Node
@export var scnLoader: Node
@export var regularPath: String
@export var eggPath: String
@export var debug_egg: bool

func _ready() -> void:
	var egg = false
	if GraphicsSettings.new_game_plus:
		egg = true
	else:
		var rng = RandomNumberGenerator.new()
		# 40% chance of INTERMISSION
		if rng.randi_range(1, 100) <= 40:
			egg = true	
	
	#if debug_egg:
		#egg = true
	
	print("egg: " + str(egg))
	
	if egg:
		scnLoader.set("_scenePath", eggPath)
	else:
		scnLoader.set("_scenePath", regularPath)
