extends Control

onready var server_listener = $Server_listener
onready var server_ip_text_edit = $Background_panel/Server_ip_text_edit
onready var server_container = $Background_panel/VBoxContainer
onready var manual_setup_button = $Background_panel/Manual_setup

func _ready() -> void:
	server_ip_text_edit.hide()

func _on_Server_listener_new_server(serverInfo):
	var server_node = Global.instance_node(load("res://Server_display.tscn"), server_container)
	server_node.text = "%s - %s" % [serverInfo.ip, serverInfo.name]
	server_node.ip_address = str(serverInfo.ip)

func _on_Server_listener_remove_server(serverIp):
	for serverNode in server_container.get_children():
		if serverNode.is_in_group("Server_display"):
			if serverNode.ip_address == serverIp:
				serverNode.queue_free()
				break

func _on_Manual_setup_pressed():
	if manual_setup_button.text != "exit setup":
		server_ip_text_edit.show()
		manual_setup_button.text = "exit setup"
		server_container.hide()
		server_ip_text_edit.call_deferred("grab_focus")
	else:
		server_ip_text_edit.text = ""
		server_ip_text_edit.hide()
		manual_setup_button.text = "manual setup"
		server_container.show()

func _on_Join_server_pressed():
	Network.ip_address = server_ip_text_edit.text
	hide()
	Network.join_server()

func _on_Go_back_pressed():
	get_tree().reload_current_scene()
