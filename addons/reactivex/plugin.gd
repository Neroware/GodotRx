@tool
extends EditorPlugin


const PLUGIN_NAME = "GDRx"


func _enter_tree() -> void:
	add_autoload_singleton(PLUGIN_NAME, "res://addons/reactivex/__gdrxsingleton__.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(PLUGIN_NAME)