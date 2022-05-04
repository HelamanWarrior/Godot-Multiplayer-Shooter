extends Node

var player_master = null
var ui = null

var alive_players = []



func instance_enemy_at_location(node: Object, location: Vector2) -> Object:
	var node_instance = instance_enemy(node)
	node_instance.global_position = location
	return node_instance

func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_enemy(node: Object) -> Object:
	var node_instance = node.instance()
	$Game.add_child(node_instance)
	return node_instance
func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
