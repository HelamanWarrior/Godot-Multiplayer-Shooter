extends Node2D

var enemy_scene = preload("res://enemigo1.tscn")



var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

func _ready() -> void:
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	if get_tree().is_network_server():
		setup_players_positions()
	
	$enemy_spawn_timer.start()
	

# Cuando el usuario esta hosteando la partida se llama a esta función para que establezca las posiciones de spawn
func setup_players_positions() -> void:
	for player in Persistent_nodes.get_children():
		if player.is_in_group("Player"):
			# por cada lugar donde se puede spawnear un player...
			for spawn_location in $Spawn_locations.get_children():
				
				if int(spawn_location.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
					# Con este comando avisamos a los demás usuarios que esta posicion ya esta ocupada por este usuario
					player.rpc("update_position", spawn_location.global_position)
					# Cada posición va numerada así que sumamos uno a las posiciones
					current_spawn_location_instance_number += 1
					# Le decimos que el player de este dispositivo será el que ocupará esta posicion
					current_player_for_spawn_location_number = player

# si el player se desconecta lo borramos
func _player_disconnected(id) -> void:
	if Persistent_nodes.has_node(str(id)):
		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_nodes.get_node(str(id)).queue_free()

var rng = RandomNumberGenerator.new()

sync func instance_enemy1(id):
	var enemy1_instance = Global.instance_node_at_location(enemy_scene,Persistent_nodes, random_spawn_enemy_position())
	enemy1_instance.name = "Enemy1" + name + str(Network.networked_object_name_index)
	enemy1_instance.set_network_master(id)
	Network.networked_object_name_index += 1

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
