extends Node2D

func _ready():
	get_tree().paused = false
	GLOBAL.score = 0
	GLOBAL.checkpoint_score = 0
