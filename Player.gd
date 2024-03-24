extends Area2D
# external scenes
@export var bullet_scene : PackedScene
@export var ghost_scene : PackedScene
# movement params 
@export var playerSpeed = 200
@export var playerRotSpeed = 270
# dash mechanism 
@export var dashSpeed = 1000
var isDashing = false
var dashDuration = 0.05
var dashCoolDown = 0.8
var timeSinceLastDash = 0.0
# ghost anim
var draw_ghost = 0
# shoot mechanism 
var canShoot = true
var shootCoolDown = 0.05

func _ready():
	set_process(true)

func start(pos):
	position = pos
	$bulletCoolDown.wait_time = shootCoolDown

func _process(delta):
	$Sprite2D.frame = ($Sprite2D.frame + 1) % 5
	if timeSinceLastDash < dashCoolDown:
		timeSinceLastDash += delta
	if (Input.is_action_pressed("shoot")):
		shoot()
	var input = Input.get_vector("leftStrafe","rightStrafe","up","down")
	input = input.rotated(rotation)
	if Input.is_action_just_pressed("dash"):
		start_dash()
	var currentSpeed = calc_speed(delta)
	if (input.x != 0 || input.y != 0):
		if (draw_ghost == 5):
			create_ghost()
			draw_ghost = 0
		else :
			draw_ghost += 1 
	position += input * currentSpeed * delta
	var rot = 0
	if (Input.is_action_pressed("left")):
		rot -= playerRotSpeed
	if (Input.is_action_pressed("right")):
		rot += playerRotSpeed
	rotation += deg_to_rad(rot * delta)

func create_ghost():
	var g = ghost_scene.instantiate()
	g.position = self.position
	g.rotation = self.rotation
	get_tree().root.add_child(g)

func calc_speed(delta):
	if not isDashing:
		return playerSpeed
	var currentSpeed = dashSpeed
	dashDuration -= delta
	if dashDuration <= 0 :
		stop_dash()
	return currentSpeed

func start_dash():
	isDashing = true
	dashDuration = 0.2
	timeSinceLastDash = 0
	
func stop_dash():
	isDashing = false
	dashDuration = 0.2

func shoot():
	if not canShoot:
		return
	canShoot = false
	$bulletCoolDown.start()
	var bullet = bullet_scene.instantiate()
	var offset = Vector2(0, -20).rotated(self.rotation)
	bullet.position = self.position + offset
	bullet.rotation = self.rotation + deg_to_rad(-90)
	get_tree().root.add_child(bullet)

func _on_bullet_cool_down_timeout():
	canShoot = true


