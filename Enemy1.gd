extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 200
var velocity = Vector2()
var playerSeeking = null
var facing=0
var dir




func _ready():
	pass



func _physics_process(delta):
#	if get_tree().has_network_peer():
#		if is_network_master():	
	## EN TODOS LOS CLIENTES Y SERVIDOR
	# movimiento

	if get_tree().has_network_peer():
			if get_tree().is_network_server():
				rpc("actualizar_posicion",global_position)
	

	if playerSeeking:
		dir = (playerSeeking.global_position - global_position).normalized()
		velocity= move_and_slide(dir * speed).normalized()
		facing = look_at(playerSeeking.position)
	

remote func actualizar_posicion(pos):
	global_position=pos


sync func newPlayerSeeking(playerToSeek):
	for child in Persistent_nodes.get_children():
		if child.name == playerToSeek.name:
			playerSeeking= child

func _on_seekArea_area_entered(area):
	if get_tree().is_network_server():
		if (area.get_parent().is_in_group('Player') and playerSeeking == null):
			rpc('newPlayerSeeking', area.get_parent())
