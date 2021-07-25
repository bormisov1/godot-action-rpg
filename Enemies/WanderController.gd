extends Node2D

signal target_changed

onready var timer = $Timer
export(int) var wander_range = 32
onready var start_position = global_position
onready var target_position = global_position

func _ready():
	update_target()

func start_timer():
	var duration = rand_range(3, 5)
	timer.start(duration)

func update_target():
	target_position = start_position + Vector2(
		rand_range(-wander_range, wander_range),
		rand_range(-wander_range, wander_range))


func _on_Timer_timeout():
	emit_signal("target_changed")
	update_target()
	start_timer()
