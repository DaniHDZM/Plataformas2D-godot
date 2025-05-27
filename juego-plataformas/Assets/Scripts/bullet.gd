extends Area2D
class_name Projectile

var direction: Vector2 = Vector2.RIGHT
var speed: int = 200
var damage: int = 1

func _ready():
	# Girar el sprite según la dirección
	if direction == Vector2.LEFT:
		$Sprite2D.flip_h = true

func _physics_process(delta):
	# Mover el proyectil
	position += direction * speed * delta

func _on_body_entered(body):
	# Dañar al jugador si es tocado
	if body is Player:
		body.damage_ctrl()
		queue_free()
	# Destruir el proyectil si toca tiles/paredes
	elif body is TileMap:
		queue_free()

# Eliminar el proyectil cuando sale de la pantalla
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
