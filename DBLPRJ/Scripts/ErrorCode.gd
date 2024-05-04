extends Node

enum ERRORCODE {CORRECT,ERROR,INFO}

var ErrorText : Array = [
	"desconocido.",
	"zona vacia."
]

func MessageType(Message:String,ErrorType:ERRORCODE):
	match ErrorType:
		ERRORCODE.CORRECT:
			print_rich("[color=green]CORRECTO: [/color]" + Message)
		ERRORCODE.ERROR:
			print_rich("[color=red]ERROR: [/color]" + Message)
		ERRORCODE.INFO:
			print_rich("[color=blue]INFO: [/color]" + Message)

func MessageError(errorCode : int):
	return MessageType(ErrorText[errorCode],ERRORCODE.ERROR)
