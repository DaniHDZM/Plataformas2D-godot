extends CharacterBody2D
class_name Enemy1

@export_category("Config")
@export_group("Options")
@export var health : int = 3
@export var score : int = 100

@export_group("Motion")
@export var speed : int = -16
@export var gravity : int = 16

var direction : int = 1

func _process(_delta):
	if health > 0:
		motion_ctrl()
		
func motion_ctrl() -> void:
	$AnimatedSprite2D.scale.x = direction
	if not $AnimatedSprite2D/RayGround.is_colliding() or is_on_wall():
		direction *= -1
	
	velocity.x = direction * speed
	velocity.y += gravity
	move_and_slide()

func damage_ctrl(damage : int) -> void:
	health -= damage
	
	if health <= 0:
		$AnimatedSprite2D.set_animation("Death")
		$Collision.set_deferred("disabled", true)
		$Hit.play()
		gravity = 0
		GLOBAL.score += 100
	elif health > 0:
		$Hit.play()
		flash_red()



func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Death":
		queue_free()


func _on_area_2d_body_entered(body):
	if body is Player and health > 0:
		body.damage_ctrl()
		
func flash_red():
	$AnimatedSprite2D.modulate = Color(1, 0.2, 0.2) # rojo claro
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1) # color normal
