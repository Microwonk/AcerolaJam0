extends Node

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(_params):
	Player.instance = $Player

# `start()` is called after pre_start and after the graphic transition ends.
func start():
	pass

func _process(delta):
	pass
