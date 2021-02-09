extends Label

var ip_address = ""

func _on_Join_button_pressed():
	Network.ip_address = ip_address
	Network.join_server()
	get_parent().get_parent().queue_free()
