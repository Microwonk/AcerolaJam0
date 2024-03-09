extends Node2D

func _on_chain_body_entered(body):
	if body == Globals.player:
		body.can_climb = true

func _on_chain_body_exited(body):
	if body == Globals.player:
		body.can_climb = false
		

@onready var n_floor = $BreakableFloor
@onready var floor_particles = $FloorParticles
@onready var expl = $Explosion

var has_exploded := false

func _on_break_floor_body_entered(body):
	if body == Globals.player:
		if !has_exploded:
			n_floor.free()
			floor_particles.emitting = true
			expl.play()
			has_exploded = true

func _on_win_body_entered(body):
	pass # Replace with function body.
