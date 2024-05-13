extends Node2D

var port = 6666

func _on_host_game_pressed():
	get_tree().change_scene_to_file("res://lobby.tscn")

func _on_connect_to_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client($Address.get_text(), port)
	get_tree().get_multiplayer().multiplayer_peer = peer
	print("set as client")
	# TODO: handle the case where the client failed to connect
