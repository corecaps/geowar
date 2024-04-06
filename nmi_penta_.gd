extends Area2D
signal died
@onready var rayFolder := $Rayfolder.get_children()
var pentasISee := []
var vel := Vector2.ZERO
var speed := 300.0
var screensize : Vector2
var movv := 48
var player : Area2D
var alive = true
var TimeToLive = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	screensize = get_viewport_rect().size
	randomize()
	add_to_group("pentas")
	add_to_group("enemies")
	$Timer.wait_time = TimeToLive
	$Timer.start()
	
func start(p):
	player =  p
	$AnimationPlayer.play("alive")

func _physics_process(delta):
	if (!alive):
		return
	screensize = get_viewport_rect().size
	boids()
	#checkCollision()
	chasePlayer()
	vel = vel.normalized() * speed * delta
	rotation = lerp_angle(rotation, vel.angle_to_point(Vector2.ZERO), 0.4)
	move()



func _on_vision_area_entered(area):
	if area != self and area.is_in_group("pentas"):
		pentasISee.append(area)

func boids() -> void:
	if pentasISee && alive:
		var numOfBoids := pentasISee.size()
		var avgVel := Vector2.ZERO
		var avgPos := Vector2.ZERO
		var steerAway := Vector2.ZERO
		for penta in pentasISee:
			if (!penta):
				continue
			avgVel += penta.vel
			avgPos += penta.position
			steerAway -= (penta.global_position - global_position) * (movv/( global_position- penta.global_position).length())
		avgVel /= numOfBoids
		vel += (avgVel - vel)/2
		avgPos /= numOfBoids
		vel += (avgPos - position)
		steerAway /= numOfBoids
		vel += (steerAway)


func checkCollision() -> void:
	for ray in rayFolder:
		var r : RayCast2D = ray
		if r.is_colliding():
			if r.get_collider().is_in_group("blocks"):
				var magi := (100/(r.get_collision_point() - global_position).length_squared())
				vel -= (r.target_position.rotated(rotation) * magi)
#				vel -= (r.target_position * magi)

func chasePlayer():
	var chaseForce = (player.global_position - global_position).normalized()
	vel += chaseForce * 1.1

func move() -> void:
	global_position += vel

func die():
	alive = false
	speed = 0
	died.emit(10)
	remove_from_group("enemies")
	remove_from_group("pentas")
	$AnimationPlayer.play("death")
	$sndExplode.play()
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_vision_area_exited(area):
	if area && area.is_in_group("pentase"):
		pentasISee.erase(area)

func _on_area_entered(area):
	if area && area.is_in_group("player"):
		area.shield -= 5
		die()


func _on_timer_timeout():
	alive = false
	speed = 0
	remove_from_group("enemies")
	remove_from_group("pentas")
	queue_free()

