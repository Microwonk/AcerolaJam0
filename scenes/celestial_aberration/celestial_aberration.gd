extends Node2D

@onready var back_leg_target = $LegBIKTarget
@onready var front_leg_target = $LegFIKTarget
@onready var neck_target = $NeckIKTarget
@onready var looking_at = $NeckIKTarget/HeadLookAtTarget
@onready var body = $skeleton/Body

@export var move_speed: float = 0.2
@export var desired_offset: float = 10.0
@export var lerp_factor_flip: float = 0.05
@export var lerp_factor_body: float = 0.01
@export var lerp_factor_head: float = 0.01

func _physics_process(delta):
	global_position.x += 0.1
	
func _process(delta):
	# TODO
	# PLANE
	
	#var avg = (back_leg_target.position + front_leg_target.position) / 2
	#var target_pos = avg + transform.y * desired_offset
	#var distance = transform.y.dot(target_pos - position)
	#body.position = lerp(body.position, body.position + body.transform.y * distance, move_speed * delta)
	
	look_at_player()
	body_toward_player()
	
func look_at_player():
	looking_at.global_position = lerp(looking_at.global_position, Player.instance.get_position(), 0.1)
	if (global_position.x - looking_at.global_position.x) * self.scale.x < 0 or abs(self.scale.x) != 1:
		flip_horizontally()
	
func flip_horizontally():
	var target_scale_x = sign(Player.instance.global_position.x - global_position.x)	
	self.scale.x = lerp(self.scale.x, -target_scale_x, 0.05)
	
func body_toward_player():
	var player_position = Player.instance.get_position()
	var target_y = lerp(neck_target.global_position.y, player_position.y, lerp_factor_body)
	# clamp targets, so the body doesnt overshoot
	var max_y = global_position.y + 10;
	var min_y = global_position.y - 10;
	neck_target.global_position.y = clamp(target_y, min_y, max_y) - 0.3
