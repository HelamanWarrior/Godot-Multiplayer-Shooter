extends Camera2D

var target_player = null

func _process(delta: float) -> void:
	if Global.player_master != null:
		global_position = lerp(global_position, Global.player_master.global_position, delta * 10)
	else:
		if Global.alive_players.size() >= 1:
			if target_player == null:
				target_player = Global.alive_players[round(rand_range(0, Global.alive_players.size() - 1))]
			else:
				global_position = lerp(global_position, target_player.global_position, delta * 10)
