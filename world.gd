extends Node3D

const PORT = 13333
const IP_ADDRESS = "192.168.178.43"
const MAX_CLIENTS = 2

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene


func _on_host_button_pressed() -> void:
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()


func _on_join_button_pressed() -> void:
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer


func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
