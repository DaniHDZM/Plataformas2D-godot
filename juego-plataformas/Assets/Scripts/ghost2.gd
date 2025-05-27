extends CharacterBody2D
class_name GhostEnemy

@export_category("Config")
@export_group("Health")
@export var health: int = 3
@export var score: int = 150

@export_group("Movement")
@export var speed: int = -50
@export var patrol_distance: float = 100.0  # Distancia de patrulla antes de girar
@export var gravity: int = 16

@export_group("Ghost Behavior")
@export var visible_time: float = 3.0      # Tiempo que permanece visible
@export var invisible_time: float = 2.0    # Tiempo que permanece invisible
@export var fade_duration: float = 0.5     # Tiempo de transición al aparecer/desaparecer

# Variables de control
var direction: int = 1
var initial_position: Vector2
var is_dead: bool = false
var is_visible_to_player: bool = true
var can_damage: bool = true
var current_tween: Tween

func _ready():
	# Guardar posición inicial para calcular distancia de patrulla
	initial_position = global_position
	
	# Configurar el temporizador de visibilidad
	$VisibilityTimer.wait_time = visible_time
	$VisibilityTimer.start()
	
	# Iniciar animación
	$AnimatedSprite2D.play("Move")

func _physics_process(delta):
	if is_dead:
		return
		
	# Solo aplicar movimiento si está visible
	if is_visible_to_player:
		motion_ctrl()

func motion_ctrl() -> void:
	# Actualizar orientación del sprite
	$AnimatedSprite2D.scale.x = direction
	
	# Controlar punto de giro según la distancia recorrida
	var distance_from_start = abs(global_position.x - initial_position.x)
	if distance_from_start >= patrol_distance:
		direction *= -1
		initial_position = global_position  # Resetear el punto de referencia
	
	# Detectar paredes o bordes
	if not $RayGround.is_colliding() or is_on_wall():
		direction *= -1
	
	# Aplicar movimiento
	velocity.x = direction * speed
	velocity.y += gravity
	move_and_slide()

func damage_ctrl(damage: int = 1) -> void:
	# Solo recibir daño si está visible
	if not is_visible_to_player:
		return
		
	health -= damage
	
	if health <= 0 and not is_dead:
		is_dead = true
		$AnimatedSprite2D.play("Death")
		$CollisionShape2D.set_deferred("disabled", true)
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
		$DeathSound.play()
		GLOBAL.score += score
	elif health > 0:
		$DeathSound.play()
		flash_red()
		

func _on_visibility_timer_timeout():
	if is_dead:
		return
		
	if is_visible_to_player:
		# Cambiar a invisible
		fade_out()
		$VisibilityTimer.wait_time = invisible_time
	else:
		# Cambiar a visible
		fade_in()
		$VisibilityTimer.wait_time = visible_time
	
	$VisibilityTimer.start()

func fade_out():
	# Cancelar tween anterior si existe
	if current_tween:
		current_tween.kill()
	
	# Crear nuevo tween para desvanecer
	current_tween = create_tween()
	current_tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1, 0), fade_duration)
	current_tween.tween_callback(func(): 
		is_visible_to_player = false
		can_damage = false
		$CollisionShape2D.set_deferred("disabled", true)  # Desactivar colisión física
		$HitBox/CollisionShape2D.set_deferred("disabled", true)  # Desactivar hitbox
	)

func fade_in():
	# Cancelar tween anterior si existe
	if current_tween:
		current_tween.kill()
	
	# Activar colisiones antes de la animación
	is_visible_to_player = true
	can_damage = true
	$CollisionShape2D.set_deferred("disabled", false)
	$HitBox/CollisionShape2D.set_deferred("disabled", false)
	
	# Crear nuevo tween para aparecer
	current_tween = create_tween()
	current_tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1, 1), fade_duration)

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Death":
		queue_free()

func _on_hit_box_body_entered(body):
	# Dañar al jugador solo si el fantasma está visible
	if body is Player and can_damage and health > 0:
		body.damage_ctrl()
		
func flash_red():
	$AnimatedSprite2D.modulate = Color(1, 0.2, 0.2) # rojo claro
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1) # color normal
