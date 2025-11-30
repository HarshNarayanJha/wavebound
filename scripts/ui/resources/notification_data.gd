class_name NotificationData extends Resource

enum NotifType {
	INFO,
	TASK,
	FATAL
}

class Notif extends RefCounted:
	var text: String
	var type: NotifType
	var timeout: float

var notifications: Array[Notif]
var current_task: Notif

signal new_notification(notif: Notif)
signal set_task(notif: Notif)

func init() -> void:
	notifications.clear()
	current_task = null

func send_notification(text: String, type: NotifType, timeout: float = 5) -> void:
	var notif = Notif.new()
	notif.text = text
	notif.type = type
	notif.timeout = timeout
	notifications.push_back(notif)
	if type == NotifType.TASK:
		current_task = notif
		set_task.emit(notif)
	else:
		new_notification.emit(notif)
