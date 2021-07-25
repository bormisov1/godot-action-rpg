extends Node

signal no_health
signal health_changed(value)

export(int) var max_health = 4
onready var health = max_health setget set_health

func set_health(value):
	emit_signal("health_changed", value)
	health = value
	if health <= 0:
		emit_signal("no_health")
