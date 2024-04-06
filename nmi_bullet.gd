extends Area2D
@export var bulletSpeed = 400
var timeToLive = 1.5
var direction : Vector2
func _ready():
	$AnimationPlayer.play("default")
	$keepAlive.wait_time = timeToLive
	$keepAlive.start()
func start(dir):
	direction = dir

func _process(delta):
	position += direction.normalized() * bulletSpeed * delta


func _on_area_entered(area):
	if area.is_in_group("player") :
		area.shield -= 1
		queue_free()


func _on_keep_alive_timeout():
	queue_free()
