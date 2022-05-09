extends Node

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 6

var enemy_scene = preload("res://enemigo1.tscn")

var server = null
var client = null

var ip_address = ""
var current_player_username = ""

var client_connected_to_server = false

var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

# creamos un timer que iniciará cuando se ejecute la funcion joinServer
onready var client_connection_timeout_timer = Timer.new()

func _ready() -> void:
	# añadimos el timer i iniciamos a 10 segundos. con el one_shot le decimos que solo se ejecute una vez
	add_child(client_connection_timeout_timer)
	client_connection_timeout_timer.wait_time = 10
	client_connection_timeout_timer.one_shot = true
	
	client_connection_timeout_timer.connect("timeout", self, "_client_connection_timeout")
	
	# Teniendo en cuenta que se podrá jugar en distintos sistemas operativos y que en cada uno la ip que se quiere esta en una posición distinta, hacemos una criba para que no haya errores
	if OS.get_name() == "Windows":
		ip_address = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		ip_address = IP.get_local_addresses()[0]
	else:
		ip_address = IP.get_local_addresses()[3]
	
	# una vez tenemos el array de local adresses buscaremos aquella que corresponda con la conexión wlan que use el cliente
	# para hacerlo descartamos todas aquellas que no empiezan por 192.168 y descartamos tambien las que acaban en 1 como 127.0.0.1 o 192.168.X.1
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			# La ip que cumple los requisitos pasa a ser la ip_adress del servidor
			ip_address = ip
	
	# Existen varios casos que se pueden dar. que el usuario se conecte al servidor, que el servidor se desconecte y que la conexión falle
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")

# creamos el servidor
func create_server() -> void:
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	
	get_tree().set_network_peer(server)
	Global.instance_node(load("res://Server_advertiser.tscn"), get_tree().current_scene)

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	client_connection_timeout_timer.start()  # Esto es 

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



# enemigos

var rng = RandomNumberGenerator.new()

func instance_enemy1(id):
	var enemy1_instance = Global.instance_node_at_location(enemy_scene,Global, random_spawn_enemy_position())
	enemy1_instance.name = "Enemy1" + name + str(Network.networked_object_name_index)
	enemy1_instance.set_network_master(1)
	add_child(enemy1_instance)

func _on_enemy_spawn_timer_timeout():
	rpc("instance_enemy1", get_tree().get_network_unique_id())
	
	
func random_spawn_enemy_position():
	var randomPlace= rng.randi_range(1,4)
	
	if (randomPlace==1):
		return $Spawn_enemy/spawn.position
	elif (randomPlace==2):
		return $Spawn_enemy/spawn2.position
	elif (randomPlace==3):
		return $Spawn_enemy/spawn3.position
	elif (randomPlace==4):
		return $Spawn_enemy/spawn4.position
