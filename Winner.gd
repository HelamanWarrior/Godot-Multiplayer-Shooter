extends Label

sync func return_to_lobby():
	get_tree().change_scene("res://Network_setup.tscn")

func _on_Win_timer_timeout():
	if get_tree().is_network_server():
		rpc("return_to_lobby")
