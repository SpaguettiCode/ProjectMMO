extends Node

var eNet = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene = preload("res://Player/player.tscn")

var IDData = 0

#region Cliente
func Client_Connection(adress:String,Port:int):
	var err = eNet.create_client(adress,Port)
	if err != OK:
		LoggData.error("Error al conectar al servidor",err)
	else:
		LoggData.info("Conexion establecida")
	multiplayer.multiplayer_peer = eNet
	#_add_player(eNet.get_unique_id())
#endregion

#region Server
func Server_Connection(port:int):
	var err = eNet.create_server(port,32)
	if err != OK:
		LoggData.error("Fallo de servidor: no inicio",err)
	else:
		LoggData.info("Servidor iniciado." ,err)
		multiplayer.multiplayer_peer = eNet
#endregion
