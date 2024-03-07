extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	var swivel_speed = 0.5

	var amplitude = 5
	var frequency = 2

	var movement_x = amplitude * sin(frequency * Time.get_ticks_msec() / 1000)

	$Rope2.global_position.x += movement_x * swivel_speed

	$Rope3.global_position.x += movement_x * swivel_speed


func _on_chain_body_entered(body):
	if body == Globals.player:
		body.can_climb = true
		print(body.can_climb)				

func _on_chain_body_exited(body):
	if body == Globals.player:
		body.can_climb = false
		print(body.can_climb)
		
