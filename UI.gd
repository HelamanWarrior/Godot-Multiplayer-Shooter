extends CanvasLayer

func _ready() -> void:
	Global.ui = self

func _exit_tree() -> void:
	Global.ui = null
