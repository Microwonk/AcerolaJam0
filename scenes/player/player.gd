extends CharacterBody2D
signal jumped(is_ground_jump: bool)
signal hit_ground()

@export var input_left: String = "move_left"
@export var input_right: String = "move_right"
@export var input_jump: String = "jump"
@export var input_sneak: String = "sneak"
@export var input_light: String = "light"

const DEFAULT_MAX_JUMP_HEIGHT: float = 50
const DEFAULT_MIN_JUMP_HEIGHT: float = 30
const DEFAULT_JUMP_DURATION: float = 0.3

const LIGHT_DEACTIVATED_SIZE := 0.2
const LIGHT_ACTIVATED_SIZE := 2.0

# state types
enum PlayerState { 
	IDLE, 
	WALKING, 
	RUNNING, 
	JUMPING, 
	FALLING 
}

enum LookingState {
	RIGHT,
	LEFT
}

enum Light {
	ON,
	OFF
}

var _max_jump_height := DEFAULT_MAX_JUMP_HEIGHT
@export var max_jump_height: float = DEFAULT_MAX_JUMP_HEIGHT: 
	get:
		return _max_jump_height
	set(value):
		_max_jump_height = value
	
		default_gravity = calculate_gravity(_max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(_max_jump_height, jump_duration)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)

var _min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT
@export var min_jump_height: float = DEFAULT_MIN_JUMP_HEIGHT: 
	get:
		return _min_jump_height
	set(value):
		_min_jump_height = value
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)

var _jump_duration: float = DEFAULT_JUMP_DURATION
@export var jump_duration: float = DEFAULT_JUMP_DURATION:
	get:
		return _jump_duration
	set(value):
		_jump_duration = value
	
		default_gravity = calculate_gravity(max_jump_height, jump_duration)
		jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
		release_gravity_multiplier = calculate_release_gravity_multiplier(
				jump_velocity, min_jump_height, default_gravity)
		
@export var falling_gravity_multiplier = 1.5
@export var max_acceleration = 2500
@export var friction = 20
@export var can_hold_jump: bool = false
@export var coyote_time: float = 0.01
@export var jump_buffer: float = 0.1

var default_gravity: float
var jump_velocity: float
var double_jump_velocity: float
var release_gravity_multiplier: float
var holding_jump := false
var sneaking := false
var _was_on_ground: bool
var acc = Vector2()

# states
var state: PlayerState = PlayerState.IDLE
var looking_state: LookingState = LookingState.RIGHT
var light_state: Light = Light.ON
var jumping = false

@onready var coyote_timer = Timer.new()
@onready var jump_buffer_timer = Timer.new()

func _init():
	default_gravity = calculate_gravity(max_jump_height, jump_duration)
	jump_velocity = calculate_jump_velocity(max_jump_height, jump_duration)
	release_gravity_multiplier = calculate_release_gravity_multiplier(
			jump_velocity, min_jump_height, default_gravity)

func _ready():
	$AnimatedSprite2D.play()
	add_child(coyote_timer)
	coyote_timer.wait_time = coyote_time
	coyote_timer.one_shot = true
	
	add_child(jump_buffer_timer)
	jump_buffer_timer.wait_time = jump_buffer
	jump_buffer_timer.one_shot = true
		
func _process(_delta):
	classify_state()
	animation()

func _input(_event):
	if Input.is_action_just_pressed(input_light):
		$Flashlight.play()
		# modulate state here instead of in the classify state method
		light_state = Light.ON if light_state == Light.OFF else Light.OFF
		$PlayerLight.texture_scale = LIGHT_DEACTIVATED_SIZE if light_state == Light.OFF else LIGHT_ACTIVATED_SIZE
	
	acc.x = 0
	if Input.is_action_pressed(input_left):
		acc.x = -max_acceleration
	
	if Input.is_action_pressed(input_right):
		acc.x = max_acceleration
	
	if Input.is_action_just_pressed(input_jump):
		holding_jump = true
		start_jump_buffer_timer()
		if !can_hold_jump and can_jump():
			jump()
		
	if Input.is_action_just_released(input_jump):
		holding_jump = false
		
	if Input.is_action_pressed(input_sneak):
		sneaking = true
		acc.x /= 8
	else:
		sneaking = false

# movement
func _physics_process(delta):
	if !is_on_floor() and !jumping:
		start_coyote_timer()

	# Check if we just hit the ground this frame
	if not _was_on_ground and is_on_floor():
		jumping = false
		if is_jump_buffer_timer_running() and not can_hold_jump: 
			jump()
		hit_ground.emit()

	# Cannot do this in _input because it needs to be checked every frame
	if Input.is_action_pressed(input_jump):
		if can_jump() and can_hold_jump:
			jump()

	var gravity = apply_gravity_multipliers_to(default_gravity)
	acc.y = gravity

	# Apply friction
	velocity.x *= 1 / (1 + (delta * friction))
	velocity += acc * delta
		
	_was_on_ground = is_on_floor()
	move_and_slide()

	classify_state()
	animation()
	sound()

# classifies playerstate
func classify_state():
	if velocity.x < 0:
		looking_state = LookingState.LEFT
	elif velocity.x > 0:
		looking_state = LookingState.RIGHT
	# stay on zero velocity	
	
	if velocity.x == 0:
		state = PlayerState.IDLE
	if abs(velocity.x) > 0:
		if sneaking:
			state = PlayerState.WALKING
		else:
			state = PlayerState.RUNNING
	if velocity.y < 0:
		state = PlayerState.JUMPING
	if velocity.y > 0 and not is_on_floor():
		state = PlayerState.FALLING
		
# animates the player based on state
func animation():
	match looking_state:
		LookingState.RIGHT:
			$AnimatedSprite2D.flip_h = false
		LookingState.LEFT:
			$AnimatedSprite2D.flip_h = true
		
	match state:
		PlayerState.JUMPING:
			$AnimatedSprite2D.animation = "jump"
		PlayerState.WALKING:
			$AnimatedSprite2D.animation = "walk"
		PlayerState.RUNNING:
			$AnimatedSprite2D.animation = "run"
		PlayerState.IDLE:
			$AnimatedSprite2D.animation = "idle"
		PlayerState.FALLING:
			$AnimatedSprite2D.animation = "fall"
			
func sound():
	match state:
		PlayerState.JUMPING:
			print("jump")
		PlayerState.WALKING:
			print("walk")
		PlayerState.RUNNING:
			if !$FootSteps.is_playing():
				$FootSteps.play()
		PlayerState.IDLE:
			print("idle")
		PlayerState.FALLING:
			print("fall")
	
		
func start_coyote_timer():
	coyote_timer.start()

func start_jump_buffer_timer():
	jump_buffer_timer.start()

func is_coyote_timer_running():
	return not coyote_timer.is_stopped()

func is_jump_buffer_timer_running():
	return not jump_buffer_timer.is_stopped()

func can_jump() -> bool:
	return is_on_floor() or is_coyote_timer_running()

func jump():
	velocity.y = -jump_velocity
	jumping = true
	coyote_timer.stop()
	$AnimatedSprite2D.play("jump")
	jumped.emit(true)

func apply_gravity_multipliers_to(gravity) -> float:
	if velocity.y * sign(default_gravity) > 0: # If we are falling
		gravity *= falling_gravity_multiplier
	
	# if we released jump and are still rising
	elif velocity.y * sign(default_gravity) < 0:
		if not holding_jump: 
			gravity *= release_gravity_multiplier # multiply the gravity so we have a lower jump
	
	return gravity


## Calculates the desired gravity from jump height and jump duration.  [br]
## Formula is from [url=https://www.youtube.com/watch?v=hG9SzQxaCm8]this video[/url] 
func calculate_gravity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / pow(p_jump_duration, 2)


## Calculates the desired jump velocity from jump height and jump duration.
func calculate_jump_velocity(p_max_jump_height, p_jump_duration):
	return (2 * p_max_jump_height) / (p_jump_duration)


## Calculates jump velocity from jump height and gravity.  [br]
## Formula from 
## [url]https://sciencing.com/acceleration-velocity-distance-7779124.html#:~:text=in%20every%20step.-,Starting%20from%3A,-v%5E2%3Du[/url]
func calculate_jump_velocity2(p_max_jump_height, p_gravity):
	return sqrt(abs(2 * p_gravity * p_max_jump_height)) * sign(p_max_jump_height)


## Calculates the gravity when the key is released based off the minimum jump height and jump velocity.  [br]
## Formula is from [url]https://sciencing.com/acceleration-velocity-distance-7779124.html[/url]
func calculate_release_gravity_multiplier(p_jump_velocity, p_min_jump_height, p_gravity):
	var release_gravity = pow(p_jump_velocity, 2) / (2 * p_min_jump_height)
	return release_gravity / p_gravity


## Returns a value for friction that will hit the max speed after 90% of time_to_max seconds.  [br]
## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_friction(time_to_max):
	return 1 - (2.30259 / time_to_max)


## Formula from [url]https://www.reddit.com/r/gamedev/comments/bdbery/comment/ekxw9g4/?utm_source=share&utm_medium=web2x&context=3[/url]
func calculate_speed(p_max_speed, p_friction):
	return (p_max_speed / p_friction) - p_max_speed
