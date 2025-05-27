extends Area2D


func _on_body_entered(body):
	if body is Player:
		$AnimatedSprite2D.set_animation("Off")
		$Sound.play()
		GLOBAL.score += 100

func _on_audio_stream_player_finished():
	queue_free()
