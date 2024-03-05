extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_chain_body_entered(body):
	if body == Globals.player:
		print("entered ladder")

func _on_chain_body_exited(body):
	if body == Globals.player:
		print("exited ladder")
