class_name CLogger extends Node

static func d(tag: String, message: String) -> void:
	print_rich("[color=orange]" + tag + "[/color]: " + message)

static func l(tag: String, message: String) -> void:
	print_rich("[color=skyblue]" + tag + "[/color]: " + message)

static func e(tag: String, message: String) -> void:
	print_stack()
	print_rich("[color=red]" + tag + "[/color]: " + message)
