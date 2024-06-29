extends Node2D

var port = 6666

func _ready():
	multiplayer.connected_to_server.connect(connected)
	multiplayer.connection_failed.connect(failed_to_connect)

func _on_host_game_pressed():
	get_tree().change_scene_to_file("res://lobby.tscn")

func _on_connect_to_pressed():
	print("going to try to connect")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client($Address.get_text(), port)
	if error:
		print("failed to connect: " + str(error))
		# TODO: display an error to the player
		return
	get_tree().get_multiplayer().multiplayer_peer = peer
	# TODO: print a message saying it's connecting, give the possibility to cancel, ...

func _input(event):
	if $Address.has_focus() and event.is_action_pressed("submit_form"):
		get_viewport().set_input_as_handled()
		_on_connect_to_pressed()

func connected():
	print("Connected to server")
	get_tree().change_scene_to_file("res://board.tscn")

func failed_to_connect():
	print("failed to connect")
	# TODO: display an error
