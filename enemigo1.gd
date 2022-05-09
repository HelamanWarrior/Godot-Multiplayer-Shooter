extends KinematicBody2D



var speed = 250

var velocity = Vector2(0, 0)
var facing = 0
var player = null

puppet var puppet_vectorPosicion = Vector2()
puppet var puppet_facing = 0
puppet var puppet_playerSeeking = null


func _physics_process(delta):
	if (player):
		var direction = (player.position - position).normalized()
		move_and_slide(direction * speed)
		facing = look_at(player.position)



func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		player = body
		


func _on_hurtBox_area_entered(area):
	if (area.is_in_group("Player_damager")):
		queue_free()
	if (is_network_master()):  # se esta ejecutando esta instancia en el cliente que controla el nodo.
		if (player):
			var posPlayer = (player.global_position - position).normalized()
			velocity = move_and_slide(posPlayer * speed)
			facing = look_at(posPlayer)
		rset_unreliable('puppet_vectorPosicion', velocity)
		rset_unreliable('puppet_facing',facing)
		rset_unreliable('puppet_playerSeeking', player)
			
	else:   # # se esta ejecutando esta instancia en el cliente que NO controla el nodo.
		velocity = puppet_vectorPosicion
		facing = puppet_facing
		player = puppet_playerSeeking
	
	if get_tree().has_network_peer():   # Se ejecuta en el servidor 
			if get_tree().is_network_server():
				pass

sync func destruir():  # Esto se ejecuta de forma sincronizada en todos los clientes Que es sincronizado?
	queue_free()

func _on_zonaDeteccionEnemigos_body_entered(body):
	if (get_tree().has_network_peer()):
		if get_tree().is_network_server():
			if (body.is_in_group("Player")):
				rset('slave_playerSeeking',body)
				player=body


func _on_hurtBox_body_entered(body):
	if (get_tree().has_network_peer()):
		if get_tree().is_network_server():
			if (body.is_in_group("Player_bullet")):
				rpc('destruir')
