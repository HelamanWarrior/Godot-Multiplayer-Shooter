extends Control

var player = load("res://Player.tscn")
var enemy_scene = preload("res://Enemy1.tscn")

var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

onready var multiplayer_config_ui = $Multiplayer_configure
onready var username_text_edit = $Multiplayer_configure/Username_text_edit

onready var device_ip_address = $UI/Device_ip_address
onready var start_game = $UI/Start_game

func _ready() -> void:
	# Conectamos señales/triggers para ejecutar los metodos correspondientes cuando se activen
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	# guardamos la ip como texto en el nodo UI para mostrarla por pantalla. 
	# Como la variable tiene la etiqueta onready, una vez hecho esto se mostrará automaticamente
	device_ip_address.text = Network.ip_address
	$EnemySpawnTimer.start()
	
	# Si ya hay alguna conexión
	if get_tree().network_peer != null:
		
		# la UI no se muestra
		multiplayer_config_ui.hide()
		
		current_spawn_location_instance_number = 1
		for player in Persistent_nodes.get_children():
			if player.is_in_group("Player"):
				for spawn_location in $Spawn_locations.get_children():
					if int(spawn_location.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
						player.rpc("update_position", spawn_location.global_position)
						player.rpc("enable")
						current_spawn_location_instance_number += 1
						current_player_for_spawn_location_number = player
	else:
		# Si no hay una conexión 
		start_game.hide()
		

# muestra el boton de 'start game' si hay mas de 1 jugador 
func _process(_delta: float) -> void:
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			start_game.show()
		else:
			start_game.hide()


# Mostramos en terminal que efectivamente se ha conectado un player y mostramos la id del player
func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	# creamos la instancia del player con sus atributos
	instance_player(id)

# en caso de desconexión del player que ha creado la partida, mostramos por terminal que se ha desconectado el player con la id que tenga. 
func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	
	# Además borramos la partida si se trata del jugador que hostea la partida
	if Persistent_nodes.has_node(str(id)):
		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_nodes.get_node(str(id)).queue_free()

# Cuando se pulse el botón de crear servidor
func _on_Create_server_pressed():
	# Con este if comprobamos que el usuario se ha puesto un nombre. Si no no sucede nada
	if username_text_edit.text != "":
		# Le ponemos al usuario el nombre elegido
		Network.current_player_username = username_text_edit.text
		# escondemos el menú
		multiplayer_config_ui.hide()
		# creamos el servidor
		Network.create_server()
	
		# Le passamos al server la id para crear una instancia de player
		instance_player(get_tree().get_network_unique_id())

# cuando pulsamos el botón de unirse
func _on_Join_server_pressed():
	# comprobamos que se ha introducido un nombre
	if username_text_edit.text != "":
		# escondemos el menú inicial i el edit text del username
		multiplayer_config_ui.hide()
		username_text_edit.hide()
		
		# instanciamos la escena Server_browser 
		Global.instance_node(load("res://Server_browser.tscn"), self)

# Al conectarse al servidor (entramos al waiting room)
func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())
	
	# TODO: Añadir el respawn automatico en el waiting room a continuación  

# inicia la instancia de player y le da los atributos necesarios
func instance_player(id) -> void:
	var player_instance = Global.instance_node_at_location(player, Persistent_nodes, get_node("Spawn_locations/" + str(current_spawn_location_instance_number)).global_position)
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	# le da el nombre que hayamos puesto en el editText
	player_instance.username = username_text_edit.text
	# suma uno a las posiciones de spawn de los jugadores para que el siguiente aparezca en otra posición
	current_spawn_location_instance_number += 1

# le dice a todos los users que inicien la partida (así entran todos a la vez sincronizados)
func _on_Start_game_pressed():
	rpc("switch_to_game")


sync func switch_to_game() -> void:
	# por cada user
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Player"):
			# activamos los disparos ya que en la sala de espera no hay pistolas ni ataques
			child.update_shoot_mode(true)
	# iniciamos la escena del juego en el arbol de nodos
	get_tree().change_scene("res://Game.tscn")



#  ---- ENEMIGOS ----
#Ejecutamos la creación del enemigo en todos los clientes
sync func instance_enemy1(id):
	var enemy1_instance = Global.instance_node_at_location(enemy_scene,Persistent_nodes, random_spawn_enemy_position())
	enemy1_instance.name = name + str(Network.networked_object_name_index)
	enemy1_instance.set_network_master(1)
	Network.networked_object_name_index += 1
	



# El random habria que hacerlo como el de el player en Network. De moento se queda así
var rng = RandomNumberGenerator.new()

func random_spawn_enemy_position():
	var randomPlace= rng.randi_range(1,4)

	if (randomPlace==1):
		return $Spawn_enemies/e1.position
	elif (randomPlace==2):
		return $Spawn_enemies/e2.position
	elif (randomPlace==3):
		return $Spawn_enemies/e3.position
	elif (randomPlace==4):
		return $Spawn_enemies/e4.position



func _on_EnemySpawnTimer_timeout():
	# siempre desde el server
	if (get_tree().is_network_server()):
		# Llamamos a la funcion crear enemigo al cual le mandamos la id de quien lo crea
		rpc("instance_enemy1",get_tree().get_network_unique_id())
