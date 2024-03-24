extends Node2D
@export var PlayerScene : PackedScene
var Player : Area2D
@onready var screensize = get_viewport_rect().size


func _ready():
	Player = PlayerScene.instantiate()
	get_tree().root.add_child.call_deferred(Player)
	Player.start(Vector2(screensize.x / 2,screensize.y / 2))


func _process(_delta):
	$CanvasLayer/hudPositionLabel.text = "Player Position x :" + str(Player.position.x) + " y: " + str(Player.position.y)

func _on_button_pressed():
	get_tree().quit()
	
func getPlayerPos():
	return Player.position
