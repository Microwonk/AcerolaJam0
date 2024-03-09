extends Control

@onready var btn_play = $MarginContainer/Control/VBoxContainer/PlayButton
@onready var btn_exit = $MarginContainer/Control/VBoxContainer/ExitButton


func _ready():
	if OS.has_feature('web'):
		btn_exit.queue_free() # exit button dosn't make sense on HTML5
	$AudioStreamPlayer.play()


func _on_PlayButton_pressed() -> void:
	$AudioStreamPlayer.stop()
	Game.change_scene_to_file("res://scenes/intro/intro.tscn")


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.fade_in({
			'show_progress_bar': false
		})
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()
	$AudioStreamPlayer.stop()	
