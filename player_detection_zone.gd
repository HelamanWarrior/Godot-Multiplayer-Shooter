extends Area2D


var player = null

func ver_jugador():
	return player != null



func _on_player_detection_zone_body_entered(body):
	if (body.is_in_group("Player")):
		player = body


