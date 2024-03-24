extends Area2D

@export var bulletSpeed = 1400
var timeToLive = 0.4

func _ready():
	var direction = Vector2 (cos(rotation),sin(rotation))
	position += direction.normalized() * bulletSpeed * get_physics_process_delta_time()
	$keepAliveTimer.wait_time = timeToLive
	$keepAliveTimer.start()

func _process(delta):
	var direction = Vector2 (cos(rotation),sin(rotation))
	position += direction.normalized() * bulletSpeed * delta

func _on_keep_alive_timer_timeout():
	queue_free()
