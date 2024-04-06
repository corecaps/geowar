extends Node2D
@export var radius = 100
@export var num_children = 25

func _ready():
	for i in range(num_children):
		var child_instance = Node2D.new()
		add_child(child_instance)
