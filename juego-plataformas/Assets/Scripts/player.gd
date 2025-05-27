extends CharacterBody2D
class_name Player

var axis : Vector2 = Vector2.ZERO
var death : bool = false


@export_category("Config")
@export_group("Required References")
@export var gui : CanvasLayer

@export_group("Motion")
@export var speed : int = 128
@export var gravity : int = 16
@export var jump : int = 368

func _process(_delta):
	match death:
		true:
			death_ctrl()
		false:
			motion_ctrl()

func _input(event):
	if not death and is_on_floor() and event.is_action_pressed("ui_accept") :
		jump_ctrl(1)

func get_axis() -> Vector2:
	axis.x = int(Input.is_action_pressed("ui_d")) - int(Input.is_action_pressed("ui_a"))
	return axis.normalized()
	
func motion_ctrl()-> void:
	'''MOVIMIENTO'''
	if not get_axis().x == 0:
		$AnimatedSprite2D.scale.x = get_axis().x
	
	velocity.x = get_axis().x * speed
	velocity.y += gravity
	
	move_and_slide()
	
	'''ANIMACIONES'''
	match  is_on_floor():
		true:
			if not get_axis().x == 0:
				$AnimatedSprite2D.set_animation("Run")
			else:
				$AnimatedSprite2D.set_animation("Idle")
		false:
			if velocity.y < 0:
				$AnimatedSprite2D.set_animation("Jump")
			else:
				$AnimatedSprite2D.set_animation("Fall")

func death_ctrl() -> void:
	velocity.x = 0
	velocity.y += gravity
	move_and_slide()
	
func jump_ctrl(power : float) -> void:
	velocity.y = -jump * power
	$Audio/Jump.play()
	
func damage_ctrl() -> void:
	death = true
	$AnimatedSprite2D.set_animation("Death")
	
	
func trampolin() -> void:
	jump_ctrl(2)

func _on_hit_point_body_entered(body):
	if body is Enemy or Enemy1 or PeaShooter or GhostEnemy or RockEnemy and velocity.y >= 0:
		$Audio/Hit.play()
		body.damage_ctrl(1)
		jump_ctrl(0.75)

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Death":
		gui.game_over()
