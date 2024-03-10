extends CanvasLayer

func _ready():
	$PhantomDeath.visible = false
	hide_self()

func hide_self():
	get_tree().paused = false
	self.hide()
	
func show_self():
	$Death.play()	
	get_tree().paused = true
	self.show()
	
var last_event

func _unhandled_input(event):
	if last_event and last_event.is_action_pressed("num1") and event.is_action_pressed("num2") and Globals.phantom_dead:
		get_tree().paused = false
		$MarginContainer/Control/CenterContainer/Label.text = "SACRFICED?"
		$Background.visible = false
		$PhantomDeath.visible = true
		$Static.play()
		get_viewport().set_input_as_handled()
	last_event = event	

func again():
	$Death.stop()
	Game.change_scene_to_file("res://scenes/gameplay/gameplay.tscn", {"show_progress_bar": false})

func _on_main_menu_pressed():
	$Death.stop()
	Game.change_scene_to_file("res://scenes/menu/menu.tscn", {"show_progress_bar": false})

func _on_player_died():
	show_self()

func _on_try_again_pressed():
	again()
