extends Area2D

func _process(delta):
	if GLOBAL.puerta == 0:
		$AnimatedSprite2D.play("Close")
		$CollisionShape2D.disabled = true
	elif GLOBAL.puerta == 1:
		$AnimatedSprite2D.play("Open")
		$CollisionShape2D.disabled = false
		

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().change_scene_to_file("res://Scenes/Level2.tscn")
