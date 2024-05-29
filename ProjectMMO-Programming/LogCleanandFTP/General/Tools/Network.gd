extends Node

var eNet = ENetMultiplayerPeer.new()
var ID : int

#region Cliente
func Client_Connection(adress:String,Port:int):
	var err = eNet.create_client(adress,Port)
	if err != OK:
		LoggData.error("Error al conectar al servidor",err)
	else:
		LoggData.info("Conexion establecida")
	multiplayer.multiplayer_peer = eNet
	eNet.peer_connected.connect(_on_peer_connected)

#peer connected
func _on_peer_connected(peer_id: int):
	var client_address = eNet.get_peer(peer_id).get_remote_address()
	print("Usuario conectado con IP: ",client_address)
	ID = peer_id
	print("Usuario con la ID: ",ID )
	SendDataToHost(client_address)

@rpc("any_peer","reliable")
func SendDataToHost(peer):
	SendDataToHost.rpc_id(1,peer)
	if multiplayer.is_server():
		print("Usuario conectado al servidor con la IP: ", peer)

func _on_peer_disconnected(peer_id: int):
	var client_address = eNet.get_peer(peer_id).get_host().address
	print(client_address)
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
