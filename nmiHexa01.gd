extends Area2D
signal died
@export var speed = 200
@export var rotspeed = 90
@export var timeToShoot = 0.6
@export var bullet_scene : PackedScene
var player : Area2D
func start(Player):
	player = Player
	add_to_group("enemies")
func _ready():
	$Timer.wait_time = timeToShoot
	$Timer.start()
	$AnimationPlayer.play("start")

func _process(delta):
	if player :
		var dirVector = player.position -  position
		position += dirVector.normalized() * speed * delta
		rotation += deg_to_rad(rotspeed) * delta

func die():
	speed = 0
	remove_from_group("enemies")
	set_deferred("monitoring",false)
	$AnimationPlayer.play("explode")
	$sndExplode.play()
	call_deferred("explode")
	await $AnimationPlayer.animation_finished
	died.emit(5)
	queue_free()
func explode():
	var offset = [Vector2(0,1),Vector2(1,0),Vector2(0,-1),Vector2(-1,0)]
	for i in range (4):
		var b = bullet_scene.instantiate()
		b.position = position
		b.start((position + offset[i]) - position)
		get_tree().root.add_child(b)

func _on_timer_timeout():
	var n = bullet_scene.instantiate()
	n.position = position
	n.start(player.position-position)
	get_tree().root.add_child(n)
	if ($Timer.wait_time > 0.1):
		$Timer.wait_time *= 0.98
	$Timer.start()

func _on_area_entered(area):
	if area.is_in_group("player"):
		area.shield -= 2
		die()
