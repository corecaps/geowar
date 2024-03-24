extends Area2D

@export var bulletSpeed = 400
var timeToLive = 0.75


# Called when the node enters the scene tree for the first time.
func _ready():
	var direction = Vector2 (cos(rotation),sin(rotation))
	position += direction.normalized() * bulletSpeed * get_physics_process_delta_time()
	$keepAliveTimer.wait_time = timeToLive
	$keepAliveTimer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector2 (cos(rotation),sin(rotation))
	position += direction.normalized() * bulletSpeed * delta
	var screen_size = get_viewport_rect().size
	if position.x < 0:
		position.x += screen_size.x
	elif position.x > screen_size.x:
		position.x -= screen_size.x
	if position.y < 0:
		position.y += screen_size.y
	elif position.y > screen_size.y:
		position.y -= screen_size.y

func _on_keep_alive_timer_timeout():
	queue_free()
