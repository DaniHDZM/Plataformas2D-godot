extends Area2D


func _on_body_entered(body):
	if body is Player:
		$AnimatedSprite2D.set_animation("Open")
		$Sound.play()
		GLOBAL.score += 200
	
func _on_audio_stream_player_finished():
	$CollisionShape2D.disabled = true
