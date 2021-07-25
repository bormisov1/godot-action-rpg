extends Area2D


func _on_InteractionBox_area_entered(area):
	PlayerStats.health = min(PlayerStats.health + 1, PlayerStats.max_health)
