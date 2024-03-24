extends Node2D
@export var PlayerScene : PackedScene
var Player : Area2D
@onready var screensize = get_viewport_rect().size
# Called when the node enters the scene tree for the first time.
func _ready():
	Player = PlayerScene.instantiate()
	get_tree().root.add_child.call_deferred(Player)
	Player.start(Vector2(screensize.x / 2,screensize.y / 2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
