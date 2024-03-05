extends Node2D

@onready var back_leg_target = $LegBIKTarget
@onready var front_leg_target = $LegFIKTarget
@onready var neck_target = $NeckIKTarget
@onready var neck = $skeleton/Body/Neck
@onready var looking_at = $NeckIKTarget/HeadLookAtTarget
@onready var body = $skeleton/Body

@export var move_speed: float = 20.0
@export var body_offset: float = 30.0
@export var lerp_factor_flip: float = 0.05
@export var lerp_factor_body: float = 0.01
@export var lerp_factor_head: float = 0.3

func _ready():
	$LegBIKTarget.global_position = global_position
	$LegFIKTarget.global_position = global_position
	$StepTargets.global_position.y = avg_legs().y - 20

func _physics_process(delta):
	# most minimal AI I can imagine
	global_position.x += sign(Globals.player.global_position.x - global_position.x) * move_speed * delta
	$StepTargets.global_position.y = avg_legs().y - 20
	body_toward_player(delta, 25)	
	offset(delta, body, body_offset)
	look_at_player()
	
# to function in case i need to offset something else as well
func offset(delta, element, desired_offset):
	var avg = avg_legs()
	var target_pos = avg + element.transform.y * -desired_offset
	var distance = element.transform.y.dot(target_pos - element.global_position)
	element.global_position.y = lerp(element.global_position, element.global_position + element.transform.y * distance, 9.0 * delta).y

func avg_legs() -> Vector2:
	return (back_leg_target.global_position + front_leg_target.global_position) / 2
	
func look_at_player():
	looking_at.global_position = lerp(looking_at.global_position, Globals.player.global_position, lerp_factor_head)
	flip_horizontally()
	
func flip_horizontally():
	var player_position = Globals.player.global_position
	const distance_threshold = 5
	var distance_to_player = abs(player_position.x - global_position.x)

	if distance_to_player > distance_threshold:
		var target_scale_x = -sign(player_position.x - global_position.x)    
		self.scale.x = target_scale_x
	
func body_toward_player(delta, minimum_offset):
	var avg = avg_legs()
	var target_pos = avg + neck_target.transform.y * -minimum_offset
	
	var player_position = Globals.player.global_position
	var min_y = target_pos.y - 10;
	var target_y = min(target_pos.y, clamp(player_position.y, min_y, target_pos.y))
	target_pos.y = target_y
	
	var distance = neck_target.transform.y.dot(target_pos - neck_target.global_position)
	neck_target.global_position.y = lerp(neck_target.global_position, neck_target.global_position + neck_target.transform.y * distance, 5 * delta).y
	
func _on_hit_box_body_entered(body_entered):
	if body_entered == Globals.player:
		# TODO kill player here
		print("player ded")
		# Game.restart_scene()
		
