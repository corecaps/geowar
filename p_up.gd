extends Area2D
signal pup
var Player : Area2D
@export var speed = 70
var grow = false
var applied = false
func _ready():
	$TimeToLive.wait_time = 5.0
	$TimeToLive.start()

func start(p):
	Player = p

func _process(delta):
	var dirv = Player.global_position - global_position
	global_position += dirv.normalized() * speed * delta
	var ts = $PointLight2D.get_texture_scale()
	if (grow) :
		$PointLight2D.set_texture_scale(ts + 0.1) 
	else :
		$PointLight2D.set_texture_scale(ts - 0.1)
	if (grow) && ts >= 1.0 :
		grow = false
	if (not grow) && ts <= 0.2:
		grow = true

func apply_rnd_pup():
	if (!Player):
		return
	if (applied):
		return
	else:
		applied  = true
	randomize()
	var t = randi() % 4
	$sndActivate.play()
	match t:
		0:
			Player.shield += 20
			pup.emit("shield restored !")
			return
		1:
			Player.playerSpeed += 20
			pup.emit("improved Speed !")
			return
		2:
			Player.n_bullets += 1
			pup.emit("More Bullets !")
			return
		3:
			Player.shootCoolDown -= 0.02
			pup.emit("Shoot Faster !")
			return

func _on_area_entered(area):
	if area.is_in_group("player"):
		if (!applied):
			apply_rnd_pup()
		call_deferred("queue_free")



func _on_time_to_live_timeout():
	queue_free()
