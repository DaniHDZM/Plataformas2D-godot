extends Node2D

func _ready():
	get_tree().paused = false
	GLOBAL.save_checkpoint()
