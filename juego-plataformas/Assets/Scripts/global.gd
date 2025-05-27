extends Node

var score : int
var puerta = 0

var checkpoint_score = 0

# Función para guardar el checkpoint de score
func save_checkpoint():
	checkpoint_score = score

# Función para restaurar el score al checkpoint
func restore_checkpoint():
	score = checkpoint_score
