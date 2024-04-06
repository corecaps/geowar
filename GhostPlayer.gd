extends Sprite2D

func _ready():
	modulate.a = 0.5

func _process(delta):
	modulate.a -= delta * 1.5
	if (modulate.a <= 0.05):
		queue_free()
	
