extends Node2D

var player_following = null
var text = "" setget text_set

onready var label = $Label

func _process(_delta: float) -> void:
	if player_following != null:
		global_position = player_following.global_position

func text_set(new_text) -> void:
	text = new_text
	label.text = text
