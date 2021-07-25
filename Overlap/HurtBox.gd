extends Area2D

signal invincibility_started
signal invincibility_ended

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

export(bool) var show_hit = true
var invincible = false

const HitEffect = preload("res://Effects/HitEffect.tscn")

func make_invincible(duration):
	invincible = true
	timer.start(duration)
	collisionShape.set_deferred("disabled", true)
	emit_signal("invincibility_started")

func make_hit_effect():
	var hitEffect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(hitEffect)
	hitEffect.global_position = global_position


func _on_Timer_timeout():
	invincible = false
	collisionShape.disabled = false
	emit_signal("invincibility_ended")
