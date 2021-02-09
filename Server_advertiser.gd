extends Node

export (float) var broadcast_interval = 1.0
var server_info = {"name": "LAN Game"}

var socket_udp
var broadcast_timer = Timer.new()
var broadcast_port = Network.DEFAULT_PORT

func _enter_tree():
	broadcast_timer.wait_time = broadcast_interval
	broadcast_timer.one_shot = false
	broadcast_timer.autostart = true
	
	if get_tree().is_network_server():
		add_child(broadcast_timer)
		broadcast_timer.connect("timeout", self, "broadcast")
		
		socket_udp = PacketPeerUDP.new()
		socket_udp.set_broadcast_enabled(true)
		socket_udp.set_dest_address('255.255.255.255', broadcast_port)

func broadcast():
	server_info.name = Network.current_player_username
	var packet_message = to_json(server_info)
	var packet = packet_message.to_ascii()
	socket_udp.put_packet(packet)

func _exit_tree():
	broadcast_timer.stop()
	if socket_udp != null:
		socket_udp.close()
