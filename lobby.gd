extends Node2D

var port = 6666

func _ready():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 5)
	get_tree().get_multiplayer().multiplayer_peer = peer
	multiplayer.peer_connected.connect(on_player_connected)
	print("set as server")

func on_player_connected(id):
	print("player "+ str(id) + " connected")
