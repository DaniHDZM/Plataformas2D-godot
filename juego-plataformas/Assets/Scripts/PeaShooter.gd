extends CharacterBody2D
class_name PeaShooter

@export_category("Config")
@export_group("Health")
@export var health: int = 2
@export var score: int = 200

@export_group("Attack")
@export var shoot_interval: float = 2.0
@export var projectile_speed: int = -150
@export var detection_range: float = -300.0  

var gravity: int = 16
var can_shoot: bool = true
var is_dead: bool = false
var player_in_sight: bool = false

# Precargar escena del proyectil
var projectile_scene = preload("res://Scenes/Bullet.tscn")

func _ready():
	$AnimatedSprite2D.play("Idle")
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()
	
	# Configurar el RayCast
	$VisionRayCast.enabled = true
	$VisionRayCast.target_position = Vector2(detection_range, 0)  # Ajusta según la dirección
	# Asegúrate de que la máscara de colisión esté configurada para detectar al jugador

func _process(delta):
	if is_dead:
		return
	
	# Verificar si el jugador está en rango y visible
	check_player_visibility()
	
	# Solo disparar si el jugador está en rango y es visible
	if can_shoot and player_in_sight:
		shoot()
		can_shoot = false
		$ShootTimer.start()

func _physics_process(delta):
	# Aplicar gravedad para mantenerla en el suelo
	if not is_on_floor():
		velocity.y += gravity
		move_and_slide()

func check_player_visibility():
	# Método RayCast
	if $VisionRayCast.is_colliding():
		var collider = $VisionRayCast.get_collider()
		if collider is Player:
			player_in_sight = true
			return
	
	player_in_sight = false

func shoot():
	# Reproducir animación de disparo
	$AnimatedSprite2D.play("Shoot")
	$ShootSound.play()
	
	# Crear proyectil
	var projectile = projectile_scene.instantiate()
	projectile.global_position = $ShootPosition.global_position
	projectile.direction = Vector2.RIGHT if $AnimatedSprite2D.scale.x > 0 else Vector2.LEFT
	projectile.speed = projectile_speed
	
	# Añadir el proyectil a la escena
	get_tree().current_scene.add_child(projectile)

func damage_ctrl(damage: int) -> void:
	health -= damage
	
	if health <= 0 and not is_dead:
		is_dead = true
		$AnimatedSprite2D.play("Death")
		$CollisionShape2D.set_deferred("disabled", true)
		$ShootTimer.stop()
		$DeathSound.play()
		GLOBAL.score += score
	elif health > 0:
		$DeathSound.play()
		flash_red()

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Death":
		queue_free()
	elif $AnimatedSprite2D.animation == "Shoot":
		$AnimatedSprite2D.play("Idle")

func _on_shoot_timer_timeout():
	can_shoot = true

# Área para detectar cuando el jugador salta encima
func _on_top_area_body_entered(body):
	if body is Player and health > 0:
		body.damage_ctrl()



func flash_red():
	$AnimatedSprite2D.modulate = Color(1, 0.2, 0.2) # rojo claro
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1) # color normal
