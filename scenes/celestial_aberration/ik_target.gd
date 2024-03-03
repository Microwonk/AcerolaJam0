extends Marker2D

@export var step_target: Node2D
@export var step_distance: float = 30.0

@export var other: Node2D

var is_stepping := false

func _process(_delta):
	if !is_stepping and !other.is_stepping and abs(global_position.distance_to(step_target.global_position)) > step_distance:
		step()

func step():
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position) / 2
	is_stepping = true
	
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + owner.transform.y, 0.2)
	t.tween_property(self, "global_position", target_pos, 0.2)
	t.tween_callback(func(): is_stepping = false)
