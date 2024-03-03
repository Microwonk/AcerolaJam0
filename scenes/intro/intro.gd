extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_play_button_pressed():
	$GameInsert.play()	
	$MarginContainer/Control/Story.text = "[center]Loading . . ."
	$MarginContainer/Control/VBoxContainer/PlayButton.visible = false

func _on_game_insert_finished():
	Game.change_scene_to_file("res://scenes/gameplay/Gameplay.tscn")
