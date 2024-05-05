extends Node

enum ERRORCODE {CORRECT,ERROR,INFO}

var ErrorText : Array = [
	"desconocido.",
	"zona vacia.",
	"no en area",
	"resutlado: NULL"
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
	if !errorCode >= ErrorText.size() || errorCode == null:
		return MessageType(ErrorText[errorCode],ERRORCODE.ERROR)
	else:
		return MessageType(ErrorText[0],ERRORCODE.ERROR)


