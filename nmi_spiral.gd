extends Area2D
signal died
@export var speed = 100
@export var rotspeed = 60
@export var timeToShoot = 0.1
@export var bullet_scene : PackedScene
var player : Area2D
var spawn_points = []
var radius = 50
var health = 20

func start(Player):
	player = Player
	add_to_group("enemies")

func _ready():
	$Timer.wait_time = timeToShoot
	$Timer.start()
	for i in range(8):  
		var spawn_point = Node2D.new()
		add_child(spawn_point)
		spawn_points.append(spawn_point)
		var angle = i * PI / 4  # PI / 2 radians = 90 degrees
		spawn_point.position = Vector2(cos(angle), sin(angle)) * radius

func _process(delta):
	var angle_delta = deg_to_rad(rotspeed * delta)  # Convert rotation speed to radians and adjust by delta
	for spawn_point in spawn_points:
		var angle = spawn_point.position.angle() + angle_delta  # Calculate new angle
		spawn_point.position = Vector2(cos(angle), sin(angle)) * radius
	if player :
		var dirVector = player.position -  position
		position += dirVector.normalized() * speed * delta
		var angle_to_player = (player.position - position).angle_to(Vector2(1, 0))
		rotation = angle_to_player

func die():
	health -= 1
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate",Color.RED,0.3)
	tween.tween_callback(restore_color)
func restore_color():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate",Color.WHITE,0.1)


	if (health <= 0):
		speed = 0
		remove_from_group("enemies")
		died.emit(20)
		queue_free()

func _on_timer_timeout():
	for spawn_point in spawn_points:
		var bullet = bullet_scene.instantiate()
		bullet.position = self.global_position + spawn_point.position
		# bullet.timeToLive = 1.3
		get_tree().root.add_child(bullet)
		if player:
			var direction = spawn_point.position.normalized()
			bullet.start(direction)
