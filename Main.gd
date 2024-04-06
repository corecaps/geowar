extends Node2D
@export var PlayerScene : PackedScene
@export var PentasScene : PackedScene
@export var SpiralScene : PackedScene
@export var nmiscene : PackedScene
@export var pupscene : PackedScene
var Player : Area2D
@onready var screensize = get_viewport_rect().size
@export var spawnTime = 1.2
@export var spawn_radius = 400
var score = 0
var pentasNb = 5
var hexaspeed = 50
var hexaNb = 1
var pentaspeed = 50
var SpiralNb = 1
var MaxSpiral = 4
var has_spawn_pentas = false
var playing = false
var update = 100
var since_update = 0
func _ready():
	var format_str = "Score :    %012d"
	$CanvasLayer/MarginContainer/HBoxContainer/Score.text = format_str % score
	$menu.play()
func start():
	$menu.stop()
	hexaNb = 1
	hexaspeed = 100
	pentasNb = 5
	pentaspeed = 200
	score = 0
	update = 100
	since_update = 0
	spawn_radius = 400
	has_spawn_pentas = false
	if (Player):
		Player.queue_free()
	Player = PlayerScene.instantiate()
	get_tree().root.add_child.call_deferred(Player)
	Player.start(Vector2(screensize.x / 2,screensize.y / 2))
	Player.shield_changed.connect(_on_player_shield_changed)
	$NMISpawnTimer.wait_time = spawnTime
	$NMISpawnTimer.start()
	$CanvasLayer/MarginContainer.show()
	$CanvasLayer/MarginContainer/HBoxContainer/ShieldBar.show()
	$CanvasLayer/MarginContainer/HBoxContainer/Quit.show()
	$CanvasLayer/MarginContainer/HBoxContainer/Score.show()
	playing = true
	$music.play()

func game_over():
	playing = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	while get_tree().get_nodes_in_group("enemies").size() > 0:
		await get_tree().create_timer(0.1).timeout
	Player.hide()
	Player.playerSpeed = 0
	$CanvasLayer/CenterContainer2.hide()
	$CanvasLayer/CenterContainer.show()
	$CanvasLayer/MarginContainer/HBoxContainer/ShieldBar.hide()
	$CanvasLayer/CenterContainer/VBoxContainer/HELP.text  = "GAME OVER"
	$NMISpawnTimer.stop()
	await get_tree().create_timer(4.0).timeout
	$CanvasLayer/CenterContainer/VBoxContainer/HELP.text = "PRESS START"
	$CanvasLayer/CenterContainer/VBoxContainer/start.show()
	$music.stop()
	$menu.play()

func _process(_delta):
	if (!playing):
		return
	var format_str = "Score : %012d"
	$CanvasLayer/MarginContainer/HBoxContainer/Score.text = format_str % score
	if Player != null:
		place_spawn_point()

func place_spawn_point():
	var num_children = $SpawnMain.get_child_count()
	var angle_step = 2 * PI / num_children
	for i in range (num_children):
		var child = $SpawnMain.get_child(i)
		var angle = angle_step * i
		child.position = Player.position + Vector2(cos(angle), sin(angle)) * spawn_radius

func _on_button_pressed():
	get_tree().quit()

func getPlayerPos():
	return Player.position

func spawn_pup():
	if (!playing):
		return
	var spawn_list = $SpawnMain.get_children()
	var p = pupscene.instantiate()
	var spawn_id = randi() % spawn_list.size()
	p.position = spawn_list[spawn_id].position
	p.start(Player)
	p.pup.connect(_on_pup_received)
	get_tree().root.add_child(p)

func _on_pup_received(msg):
	display_upgrade_message(1.0,msg)

func spawn_spiral():
	if (!playing):
		return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	for i in range(SpiralNb):
		if i > MaxSpiral:
			break
		var spawn_list = $SpawnMain.get_children()
		var sp = SpiralScene.instantiate()
		var spawn_id = randi() % spawn_list.size()
		sp.position = spawn_list[spawn_id].position
		sp.start(Player)
		sp.died.connect(_on_nmi_died)
		get_tree().root.add_child(sp)
	SpiralNb += 1

func _on_nmi_spawn_timer_timeout():
	if (!playing):
		return
	var spawn_list = $SpawnMain.get_children()
	if (!has_spawn_pentas):
		for i in range(pentasNb):
			var p = PentasScene.instantiate()
			var spawn_id = randi() % spawn_list.size()
			p.position = spawn_list[spawn_id].position
			p.speed = pentaspeed
			p.start(Player)
			p.died.connect(_on_nmi_died)
			get_tree().root.add_child(p)
		has_spawn_pentas = true
	for i in range (hexaNb):
		var nmi = nmiscene.instantiate()
		var si = randi() % spawn_list.size()
		nmi.position = spawn_list[si].position
		get_tree().root.add_child(nmi)
		nmi.start(Player)
		nmi.speed = hexaspeed
		nmi.died.connect(_on_nmi_died)
	if (get_tree().get_nodes_in_group("pentas").size() <= 2):
		has_spawn_pentas = false
		pentasNb += 2

func _on_nmi_died(value) :
	score += value
	if (score > 20) && (score % 1000 <= 5):
		spawn_spiral()
	if score %400 == 0:
		hexaNb += 1
	if score %100 == 0:
		pentaspeed += 1
	if score % 50 == 0:
		call_deferred("spawn_pup")
		hexaspeed += 1
		spawn_radius += 1
	since_update += value
	if (since_update >= update):
		update += update
		call_deferred("spawn_pup")


func display_upgrade_message(duration,msg):
	var label = $CanvasLayer/CenterContainer2/WeaponUpgraded
	$CanvasLayer/CenterContainer2.show()
	$CanvasLayer/CenterContainer2/WeaponUpgraded.text = msg
	label.show()
	label.modulate.a = 1
	var tween = get_tree().create_tween()
	tween.tween_property(label, "modulate:a", 0,duration)
	tween.tween_callback(hideUpgrade)

func hideUpgrade():
	$CanvasLayer/CenterContainer2.hide()
	$CanvasLayer/CenterContainer2/WeaponUpgraded.hide()

func _on_player_shield_changed(maxvalue,current) :
	$CanvasLayer/MarginContainer/HBoxContainer/ShieldBar.max_value = maxvalue
	$CanvasLayer/MarginContainer/HBoxContainer/ShieldBar.value = current
	if (current <= 0):
		game_over()

func _on_start_pressed():
	$CanvasLayer/CenterContainer.hide()
	start()
