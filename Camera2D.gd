extends Camera2D

var tremblement_actif = false
var intensite_tremblement = 10
var duree_tremblement = 0.2

func _ready():
	set_process(true)
	$Timer.wait_time = duree_tremblement

func _process(_delta):
	if tremblement_actif:
		randomize()
		offset = Vector2(randi() % intensite_tremblement * 2 - intensite_tremblement,randi() % intensite_tremblement * 2 - intensite_tremblement)
	else:
		offset = Vector2()

func declencher_tremblement(duree,intensite):
	$Timer.wait_time = duree
	intensite_tremblement = intensite
	tremblement_actif = true
	$Timer.start()

func _on_timer_timeout():
	tremblement_actif = false # Replace with function body.
