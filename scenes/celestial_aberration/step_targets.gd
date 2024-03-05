extends Node2D

@export var offset: float = 40.0

@onready var parent = get_parent()
@onready var previous_pos = parent.global_position

func _process(_delta):
	var velocity = parent.global_position - previous_pos
	global_position.x = (parent.global_position + velocity * offset).x
	
	previous_pos = parent.global_position
