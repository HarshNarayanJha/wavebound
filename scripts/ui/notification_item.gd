extends TextureRect

@export var label: Label
@export var animation: AnimationPlayer

func _ready():
	animation.play("slide_in")
	animation.animation_finished.connect(self._on_animation_finished)

func set_text(text: String) -> void:
	label.set_text(text)

func set_type(nType: NotificationData.NotifType) -> void:
	if nType == NotificationData.NotifType.INFO:
		get_tree().create_timer(3).timeout.connect(animation.play.bind("slide_out"))
	elif nType == NotificationData.NotifType.FATAL:
		label.label_settings.font_color = Color(1, 0, 0)
	elif nType == NotificationData.NotifType.TASK:
		label.label_settings.font_color = Color(0, 1, 0)

func _on_animation_finished(animation_name: String):
	if animation_name == "slide_out":
		queue_free()
