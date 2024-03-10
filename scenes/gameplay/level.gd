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
	if body == Globals.player and !Globals.phantom_dead:
		trans()
		Game.change_scene_to_file("res://scenes/gameplay/win_screen/winscreen.tscn", {"show_progress_bar": false})
		
func _on_secret_win_body_entered(body):
	if body == Globals.player:
		trans()
		Game.change_scene_to_file("res://scenes/gameplay/secret_win_screen/secretwinscreen.tscn", {"show_progress_bar": false})
	
func trans():
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
