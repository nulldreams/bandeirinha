extends Node


func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	instantiate_player()

func instantiate_player():
	var new_player = preload("res://Entities/Player/Player.tscn").instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	$World.add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position)
