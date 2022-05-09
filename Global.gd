extends Node

var player_master = null
var ui = null

var alive_players = []

# Esta funcion hace que los nodos se instancien todos en el script Global y luego devuelve la instancia del objeto
# Devuelve un objeto
func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

