extends Control

func _on_Ok_pressed():
	get_tree().change_scene("res://Network_setup.tscn")

func set_text(text) -> void:
	$Label.text = text
