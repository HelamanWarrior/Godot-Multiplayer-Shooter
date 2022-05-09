extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 200
var velocity = Vector2()
var playerSeeking = null
var hp = 1
var facing = 0

puppet var puppet_velocity = Vector2()
puppet var puppet_facing = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if get_tree().is_network_server():
		if (playerSeeking != null):
			var dir= (playerSeeking.global_position - position).normalized()
			velocity = move_and_slide(dir * speed)
			facing = look_at(playerSeeking.position)
			rpc_unreliable("set_movement",velocity,playerSeeking.position)
			
#	if (not is_network_master()):
#		print("no soy master")
#		velocity= puppet_velocity
#		facing= puppet_facing
#	else:
#		print("si soy master")
#		velocity = puppet_velocity
#		facing = puppet_facing
		
remote func set_movement(vel,fac):
	velocity=move_and_slide(vel*speed)
	#move_and_slide(vel * speed)
	facing= look_at(fac)

sync func newPlayerSeeking(playerToSeek):
	for child in Persistent_nodes.get_children():
		if child.name == playerToSeek:
			playerSeeking= child

func _on_seekArea_area_entered(area):
	if (area.get_parent().is_in_group('Player') and playerSeeking == null):
		rpc('newPlayerSeeking', area.get_parent().name)
