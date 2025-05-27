extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GLOBAL.puerta += 1
		$AudioStreamPlayer.play()
		$AnimatedSprite2D.hide()
		disconnect("body_entered", Callable(self, &"_on_body_entered"))
