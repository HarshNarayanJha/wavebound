extends TextureRect

@export var label: Label
@export var animation: AnimationPlayer

var timeout: float = 0

func _ready():
	animation.animation_finished.connect(self._on_animation_finished)

func display():
	animation.play("slide_in")

func set_text(text: String) -> void:
	label.set_text(text)

func set_timeout(tt: float) -> void:
	timeout = tt

func set_type(nType: NotificationData.NotifType) -> void:
	if timeout == 0:
		assert(false, "timeout was not set")

	if nType == NotificationData.NotifType.INFO:
		get_tree().create_timer(timeout).timeout.connect(animation.play.bind("slide_out"))
	elif nType == NotificationData.NotifType.FATAL:
		label.label_settings.font_color = Color(1, 0, 0)
	elif nType == NotificationData.NotifType.TASK:
		assert(false, "Invalid call for notification, type: TASK")


func _on_animation_finished(animation_name: String):
	if animation_name == "slide_out":
		queue_free()
