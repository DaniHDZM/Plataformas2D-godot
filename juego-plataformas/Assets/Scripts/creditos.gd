extends Node2D

func _ready():
	$AnimationPlayer.play("new_animation")
	await get_tree().create_timer(6.0).timeout
	$AnimationPlayer.play("new_animation_2")
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
