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

		if playerSeeking:
			dir = (playerSeeking.position - position).normalized()
			velocity= move_and_slide(dir * speed).normalized()
			facing = look_at(playerSeeking.position)
			
		if is_network_master():
			rpc("actualizar_posicion",position)
			rpc_unreliable("actualizar_playerSeeking",playerSeeking)
		else:
			pass
	

sync func actualizar_posicion(pos):
	position=pos

sync func actualizar_playerSeeking(p):
	playerSeeking=p

sync func newPlayerSeeking(playerToSeek):
	for child in Persistent_nodes.get_children():
		if child.name == playerToSeek:
			playerSeeking= child

func _on_seekArea_area_entered(area):
	if get_tree().is_network_server():
		if (area.get_parent().is_in_group('Player') and playerSeeking == null):
			rpc('newPlayerSeeking', area.get_parent().name)
