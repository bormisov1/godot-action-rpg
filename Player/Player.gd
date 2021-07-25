extends KinematicBody2D

var PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var sprite = $Sprite
onready var puffSprite = $PuffSprite

enum {
	MOVE,
	ROLL,
	ATTACK,
	INTERACT
}

const ACCELERATION = 1300
const MAX_SPEED = 150
const ROLL_SPEED = 220
const FRICTION = 1300
const THRESHOLD_ARRIVAL_DISTANCE = 15

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var interacting_position = null

func _ready():
	PlayerStats.health = PlayerStats.max_health
	PlayerStats.connect("no_health", self, "queue_free")
	animationTree.active = true
	animationState.travel("Idle")

func _physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	if Input.is_action_just_pressed("roll") && state == MOVE:
		state = ROLL
	match state:
		MOVE:
			handle_move_state(delta)
		ROLL:
			handle_roll_state(delta)
		ATTACK:
			handle_attack_state(delta)
		INTERACT:
			handle_interact_state(delta)

func handle_move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
	
func handle_interact_state(delta):
	if !travel_to(interacting_position, delta):
		animationState.travel("PuffJoint")

func handle_attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func handle_roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	move_and_slide(velocity)
	animationState.travel("Roll")
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE
	
func interact_animation_finished():
	velocity = Vector2.ZERO
	interacting_position = null
	state = MOVE
	print('interact_animation_finished')

func travel_to(position, delta):
	var distance = global_position.distance_to(position)
	if distance < 2:
		global_position = position
		return false
	var direction = global_position.direction_to(position)
	velocity = direction * 25
	velocity = move_and_slide(velocity)
	return true


func _on_HurtBox_area_entered(area):
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)
	PlayerStats.health -= area.damage
	hurtbox.make_invincible(1)
	hurtbox.make_hit_effect()

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_InteractionBox_area_entered(area):
	interacting_position = area.get_child(0).global_position
	state = INTERACT
