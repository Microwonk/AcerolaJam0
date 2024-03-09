extends Node2D

func _physics_process(_delta):
	var swivel_speed = 0.5

	var amplitude = 5
	var frequency = 2

	var movement_x = amplitude * sin(frequency * Time.get_ticks_msec() / 1000)

	$Rope2.global_position.x += movement_x * swivel_speed

	$Rope3.global_position.x += movement_x * swivel_speed


func _on_chain_body_entered(body):
	if body == Globals.player:
		body.can_climb = true

func _on_chain_body_exited(body):
	if body == Globals.player:
		body.can_climb = false
		


func _on_break_floor_body_entered(body):
	if body == Globals.player:
		if $BreakableFloor:
			$BreakableFloor.queue_free()
			$FloorParticles.emitting = true
			$Explosion.play()

func _on_win_body_entered(body):
	pass # Replace with function body.
