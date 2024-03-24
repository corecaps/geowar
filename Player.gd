extends Area2D

@export var bullet_scene : PackedScene
@export var playerSpeed = 200
@export var playerRotSpeed = 270
@export var dashSpeed = 1000
var isDashing = false
var dashDuration = 0.2
var dashCoolDown = 0.5
var timeSinceLastDash = 0.0

var canShoot = true
var shootCoolDown = 0.1
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

func start(pos):
	position = pos
	$bulletCoolDown.wait_time = shootCoolDown
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
	var currentSpeed = playerSpeed
	if isDashing:
		currentSpeed = dashSpeed
		dashDuration -= delta
		if dashDuration <= 0 :
			stop_dash()
	position += input * currentSpeed * delta
	var rot = 0
	if (Input.is_action_pressed("left")):
		rot -= playerRotSpeed
	if (Input.is_action_pressed("right")):
		rot += playerRotSpeed
	rotation += deg_to_rad(rot * delta)
	var screen_size = get_viewport_rect().size
	if position.x < 0:
		position.x += screen_size.x
	elif position.x > screen_size.x:
		position.x -= screen_size.x
	if position.y < 0:
		position.y += screen_size.y
	elif position.y > screen_size.y:
		position.y -= screen_size.y

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
