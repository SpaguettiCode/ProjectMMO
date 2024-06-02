extends Node

var eNet = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene = preload("res://Player/player.tscn")


#region Cliente
func Client_Connection(adress:String,Port:int):
	eNet.create_client(adress,Port)
	multiplayer.multiplayer_peer = eNet
#endregion

#region Server
func Server_Connection(port:int):
	eNet.create_server(port,32)
	multiplayer.multiplayer_peer = eNet
#endregion

