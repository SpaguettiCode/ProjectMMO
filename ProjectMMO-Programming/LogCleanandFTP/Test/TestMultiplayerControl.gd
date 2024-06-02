extends Control

@export var player_scene : PackedScene

func _on_cliente_pressed():  
	Network.Client_Connection("127.0.0.1",21)


func _on_server_pressed():
	Network.Server_Connection(21)
	multiplayer.peer_connected.connect(_add_player)
	_add_player()


func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)
