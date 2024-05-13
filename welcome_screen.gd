extends Node2D

var port = 6666

func _on_host_game_pressed():
	get_tree().change_scene_to_file("res://lobby.tscn")

func _on_connect_to_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client($Address.get_text(), port)
	if error != OK:
		print("failed to connect: " + str(error))
		# TODO: display an error to the player
	get_tree().get_multiplayer().multiplayer_peer = peer

	# TODO: print a message saying it's connecting, give the possibility to cancel, ...
	multiplayer.connected_to_server.connect(connected)
	multiplayer.connection_failed.connect(failed_to_connect)

func connected():
	print("Connected to server")
	get_tree().change_scene_to_file("res://board.tscn")

func failed_to_connect():
	print("failed to connect")
	# TODO: display an error
