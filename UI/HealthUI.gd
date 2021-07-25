extends Control

onready var healthUIEmpty = $HealthUIEmpty
onready var healthUIFull = $HealthUIFull

func set_max_health(value):
	healthUIEmpty.rect_size.x = value * 15

func set_health(value):
	healthUIFull.rect_size.x = value * 15

func _ready():
	set_max_health(PlayerStats.max_health)
	set_health(PlayerStats.health)
	PlayerStats.connect("health_changed", self, "set_health")
