@tool
extends Node

class_name FTP_Data

var ftp_host: String = "tu_host_ftp"
var host_user: String = "tu_usuario"
var host_password: String = "tu_contraseña"
var local_file_path: String = "archivo.log"
var remote_dir: String = "/ruta/destino/"

	# Crea una instancia de la clase FTPClient
var ftp_client := StreamPeerTCP.new()
var result: int = ftp_client.connect_to_host(ftp_host, 21) 


# Called when the node enters the scene tree for the first time.
func _ready():
	name = "FTPConnection"


func GoUP():
	if result == OK:
		var loggin_cmd : String = "USER" + host_user + "\r\n"
		ftp_client.put_data(loggin_cmd.to_ascii_buffer())
		var response: String = ftp_client.get_line()
		if response.begins_with("331"):
			var pass_cmd: String = "PASS " + host_password + "\r\n"
			ftp_client.put_data(pass_cmd.to_ascii_buffer())
			response = ftp_client.get_line()
			if response.begins_with("230"):
				# Cambia al directorio remoto
				var cwd_cmd: String = "CWD " + remote_dir + "\r\n"
				ftp_client.put_data(cwd_cmd.to_ascii_buffer())
				response = ftp_client.get_line()
				if response.begins_with("250"):
					# Sube el archivo
					var stor_cmd: String = "STOR " + local_file_path + "\r\n"
					ftp_client.put_data(stor_cmd.to_ascii_buffer())
					response = ftp_client.get_line()
					if response.begins_with("150"):
						LoggData.info("Archivo subido exitosamente.")
					else:
						LoggData.error("Error al subir el archivo.")
	
