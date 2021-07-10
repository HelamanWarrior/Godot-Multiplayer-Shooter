extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_address = ""
var current_player_username = ""

var client_connected_to_server = false

var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

onready var client_connection_timeout_timer = Timer.new()

func _ready() -> void:
	add_child(client_connection_timeout_timer)
	client_connection_timeout_timer.wait_time = 10
	client_connection_timeout_timer.one_shot = true
	
	client_connection_timeout_timer.connect("timeout", self, "_client_connection_timeout")

	for ip in IP.get_local_addresses():
		var ip_parts = []
		var splitter = "." if "." in ip else ":"
		for part in ip.split(splitter):
			match splitter:
				".": ip_parts.push_back(part.to_int())
				":": ip_parts.push_back(("0x" + part).hex_to_int())

		match ip_parts:
			[172, ..]:
				if ip_parts[1] in range(16, 32):
					ip_address = ip
					break
			[192, 168, ..], [10, ..]:
				ip_address = ip
				break
			[169, 254, ..]:
				if ip_parts[3] > 0:
					ip_address = ip
					break
			_:
				if ip_parts[0] in range(0xfe80, 0xfec0):
					ip_address = ip
					break
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")

func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	Global.instance_node(load("res://Server_advertiser.tscn"), get_tree().current_scene)

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	client_connection_timeout_timer.start()

func reset_network_connection() -> void:
	if get_tree().has_network_peer():
		get_tree().network_peer = null

func _connected_to_server() -> void:
	print("Successfully connected to the server")
	
	client_connected_to_server = true

func _server_disconnected() -> void:
	print("Disconnected from the server")
	
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	
	reset_network_connection()
	
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://Simple_prompt.tscn"), Global.ui)
		prompt.set_text("Disconnected from server")

func _client_connection_timeout():
	if client_connected_to_server == false:
		print("Client has been timed out")
		
		reset_network_connection()
		
		var connection_timeout_prompt = Global.instance_node(load("res://Simple_prompt.tscn"), get_tree().current_scene)
		connection_timeout_prompt.set_text("Connection timed out")

func _connection_failed():
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	
	reset_network_connection()
	
	if Global.ui != null:
		var prompt = Global.instance_node(load("res://Simple_prompt.tscn"), Global.ui)
		prompt.set_text("Connection failed")

func puppet_networked_object_name_index_set(new_value):
	networked_object_name_index = new_value

func networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)
