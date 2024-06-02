extends Control

#Aqui debes añadir el personaje jugador, con el que vas a jugar
@export var player_scene : PackedScene

#Conecta el cliente
func _on_cliente_pressed():  
	Network.Client_Connection("127.0.0.1",21)

#Crea el servidor, pero añade los personajes cuando estos se conectan(se interactua desde el servidor)
func _on_server_pressed():
	Network.Server_Connection(21)
	multiplayer.peer_connected.connect(_add_player)
	_add_player()



#Añade el personaje con un nombre(id de conexion a la escena)
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)


func _on_area_3d_area_entered(area):
	var maparea = preload("res://Scenary/lvl_test.tscn")
	get_tree().change_scene_to_file("res://Scenary/lvl_test.tscn")
