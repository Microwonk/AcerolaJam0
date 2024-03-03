extends Node2D

@export var offset: float = 20.0

@onready var parent = get_parent()
@onready var previous_pos = parent.global_position

func _process(_delta):
	var velocity = parent.global_position - previous_pos
	global_position = parent.global_position + velocity * offset
	
	previous_pos = parent.global_position
