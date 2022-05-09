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


func _physics_process(delta):
	if get_tree().is_network_server():
		print("Estoy en el servidor!") 
		if (playerSeeking != null):
			print("Tengo un player al que seguir")
			var dir= (playerSeeking.global_position - position).normalized()
			velocity = move_and_slide(dir * speed)
			facing = look_at(playerSeeking.position)
			puppet_velocity = velocity
			puppet_facing = facing
			rpc("set_movement")
			
#	if (not is_network_master()):
#		print("no soy master")
#		velocity= puppet_velocity
#		facing= puppet_facing
#	else:
#		print("si soy master")
#		velocity = puppet_velocity
#		facing = puppet_facing
		
sync func set_movement():
	velocity = puppet_velocity
	facing= puppet_facing

sync func newPlayerSeeking(playerToSeek):
	playerSeeking= playerToSeek

func _on_seekArea_area_entered(area):
	if (area.get_parent().is_in_group('Player') and playerSeeking == null):
		print("ya tengo un player al que seguir")
		rpc('newPlayerSeeking', area.get_parent())
