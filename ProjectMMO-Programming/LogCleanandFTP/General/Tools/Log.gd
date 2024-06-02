@tool
extends Node

class_name LoggData

enum LogLevel {
	DEBUG,
	INFO,
	WARN,
	ERROR,
	FATAL,
}

static var CURRENT_LOG_LEVEL=LogLevel.INFO

var FTP := HTTPClient.new()

func _ready():
	name = "Log"


static func LogMessage(message:String,log_level = LogLevel.INFO):

	var log_msg_format = "{level} [{time}]{prefix} {message} "
	var now = Time.get_datetime_dict_from_system(true)
	var msg = log_msg_format.format(
		{
			"prefix":"",
			"message":message,
			"time":"{day}/{month}/{year} {hour}:{minute}:{second}".format(now),
			"level":LogLevel.keys()[log_level]
		})
	match log_level:
		LogLevel.DEBUG:
			print(msg)
		LogLevel.INFO:
			print(msg)
		LogLevel.WARN:
			print(msg)
			push_warning(msg)
		LogLevel.ERROR:
			push_error(msg)
			printerr(msg)
		LogLevel.FATAL:
			push_error(msg)
			printerr(msg)
	FTP_Data.new().GoUP()

static func debug(message:String):
	LogMessage(message,LogLevel.DEBUG)

static func warn(message:String):
	LogMessage(message,LogLevel.WARN)

static func error(message:String,):
	LogMessage(message,LogLevel.ERROR)
	

static func fatal(message:String):
	LogMessage(message,LogLevel.FATAL)

static func info(message:String,values={}):
	LogMessage(message,values)
