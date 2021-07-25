extends Control

onready var Player = preload("res://Player/Player.tscn")

func _ready():
	PlayerStats.connect("no_health", self, "make_visible")

func make_visible():
	visible = true

func _on_TextureButton_pressed():
	visible = false
	var root = 	get_tree().get_root()
	var player = Player.instance()
	var remoteTransform = RemoteTransform2D.new()
	remoteTransform.set_remote_node(@"/root/World/Camera2D")
	player.add_child(remoteTransform)
	root.get_node("World/YSort").add_child(player)
