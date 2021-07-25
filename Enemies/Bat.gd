extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

onready var stats = $Stats
onready var sprite = $AnimatedSprite
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

enum {
	IDLE,
	WANDER,
	CHASE
}

const KNOCKBACK_FRICTION = 50
const MAX_SPEED = 100
const WANDER_MAX_SPEED = 20
const ACCELERATION = 200
const FRICTION = 400

var state = IDLE
var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var chased_body = null

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		WANDER:
			if global_position.distance_to(wanderController.target_position) < WANDER_MAX_SPEED / 4:
				state = IDLE
				continue
			move_to_position(wanderController.target_position, WANDER_MAX_SPEED, delta)
		CHASE:
			if global_position.distance_to(chased_body.global_position) < 20:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				continue
			move_to_position(chased_body.global_position, MAX_SPEED, delta)
	velocity += softCollision.get_push_vector() * delta
	velocity = move_and_slide(velocity)

func move_to_position(position, max_speed, delta):
	var direction = global_position.direction_to(position)
	velocity = velocity.move_toward(direction * max_speed, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0


func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 100

func _on_Stats_no_health():
	create_enemy_death_effect()
	queue_free()

func create_enemy_death_effect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_DetectionArea_body_entered(body):
	chased_body = body
	state = CHASE

func _on_DetectionArea_body_exited(body):
	chased_body = null
	state = IDLE


func _on_WanderController_target_changed():
	if state != CHASE:
		state = IDLE if randi() % 2 else WANDER # (randi() % 2) == random bool
