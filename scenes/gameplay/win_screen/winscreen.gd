extends Control

func _on_main_menu_pressed():
	Game.change_scene_to_file("res://scenes/menu/menu.tscn", {"show_progress_bar": false})

func _on_try_again_pressed():
	Game.change_scene_to_file("res://scenes/gameplay/gameplay.tscn", {"show_progress_bar": false})
