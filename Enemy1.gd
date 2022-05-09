extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const speed = 200

var velocity = Vector2()
var playerSeeking = null

puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree(), "idle_frame")
	
	if get_tree().has_network_peer():
		if is_network_master():
			velocity = Vector2(0,0)
			rotation = 0
			rset("puppet_velocity", velocity)
			rset("puppet_rotation", rotation)
			rset("puppet_position", global_position)

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	global_position = puppet_position


func _process(delta):
	if get_tree().has_network_peer():
		if is_network_master():
			global_position += velocity * speed * delta
		else:
			rotation = puppet_rotation
			global_position += puppet_velocity * speed * delta

sync func newPlayerSeeking(playerToSeek):
	for child in Persistent_nodes.get_children():
		if child.name == playerToSeek:
			playerSeeking= child

func _on_seekArea_area_entered(area):
	if (area.get_parent().is_in_group('Player') and playerSeeking == null):
		rpc('newPlayerSeeking', area.get_parent().name)
