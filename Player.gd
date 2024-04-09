extends Area2D
signal shield_changed
# external scenes
@export var bullet_scene : PackedScene
@export var ghost_scene : PackedScene
@export var max_shield = 100
var n_bullets = 1
var shield = max_shield:
	set = set_shield
# movement params 
@export var playerSpeed = 250
@export var playerRotSpeed = 300
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
var shootCoolDown = 0.2
func set_shield(value):
	if (value < shield):
		$Camera2D.declencher_tremblement(0.2,10)
		$sndImpact.play()
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate",Color.RED,0.2)
		tween.tween_callback(restore_color)
	shield = min(max_shield,value)
	shield_changed.emit(max_shield,shield)
	if (shield <= 0):
		$Camera2D.declencher_tremblement(2.0,30)
		hide()
func restore_color():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate",Color.WHITE,0.2)

func _ready():
	set_process(true)
	add_to_group("player")

func start(pos):
	position = pos
	$bulletCoolDown.wait_time = shootCoolDown


func _process(delta):
	$Sprite2D.frame = ($Sprite2D.frame + 1) % 4
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
	if (isDashing):
		var g = ghost_scene.instantiate()
		g.position = self.position
		g.rotation = self.rotation
		g.modulate.a = 0.9
		get_tree().root.add_child(g)

func calc_speed(delta):
	dashSpeed = playerSpeed * 4
	if not isDashing:
		return playerSpeed
	var currentSpeed = dashSpeed
	dashDuration -= delta
	if dashDuration <= 0 :
		stop_dash()
	return currentSpeed

func start_dash():
	remove_from_group("player")
	$sndDash.play()
	isDashing = true
	dashDuration = 0.2
	timeSinceLastDash = 0
	
func stop_dash():
	add_to_group("player")
	isDashing = false
	dashDuration = 0.2

func shoot():
	if (not canShoot) || (isDashing):
		return
	canShoot = false
	$bulletCoolDown.start()
	var angle_step = 5
	if n_bullets == 1:
		angle_step = 0
	var start_angle = deg_to_rad(-angle_step * (n_bullets - 1.0) / 2)
	for i in range(n_bullets):
		var bullet = bullet_scene.instantiate()
		var offset = Vector2(0, -20).rotated(self.rotation)
		bullet.position = self.position + offset
		var rotation_adjustment = start_angle + deg_to_rad(angle_step * i)
		bullet.rotation = self.rotation + rotation_adjustment + deg_to_rad(-90)
		get_tree().root.add_child(bullet)

func _on_bullet_cool_down_timeout():
	canShoot = true

func get_camera():
	return $Camera2D
