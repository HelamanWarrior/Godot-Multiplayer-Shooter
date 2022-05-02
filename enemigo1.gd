extends KinematicBody2D

#const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICCION = 200
export var WANDER_TARGET_RANGE = 4



var DISTANCE = 120
var velocidad = Vector2.ZERO
var knockback = Vector2.ZERO


onready var stats = $Stats
onready var playerDetectionZone = $player_detection_zone

onready var animationPlayer = $AnimationPlayer

func _ready():
	pass

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICCION * delta)
	knockback = move_and_slide(knockback)
	
	var player = playerDetectionZone.player
	if player != null:
		accelerate_towards_point(player.global_position, delta)

	
	


func accelerate_towards_point(point, delta):
	var direccion = global_position.direction_to(point)
	velocidad = velocidad.move_toward(direccion * MAX_SPEED, ACCELERATION * delta)




func _on_Stats_no_health():
	queue_free()
	#var enemyDeathEffect = EnemyDeathEffect.instance()
	#get_parent().add_child(enemyDeathEffect)
	#enemyDeathEffect.global_position = global_position




