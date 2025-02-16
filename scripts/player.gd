extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300
const ACCELERATION = 5
const FRICTION = 10
const DASH_VELOCITY = 250.0 
const DASH_DURATION = 0.2 
const DASH_COOLDOWN = 2.0  
const ROLL_VELOCITY = 300.0
const ROLL_DURATION = 0.3
const ROLL_COOLDOWN = 0.3  

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 800
@onready var animated_sprite = $AnimatedSprite2D
 
enum state {IDLE, RUNNING, JUMPING, ROLLING, DASHING}
var player_state = state.IDLE

var is_dashing = false
var dash_time = 0.0
var can_dash = true
var dash_cooldown_timer = 0.0  

var is_rolling = false
var roll_time = 0.0
var can_roll = true
var roll_cooldown_timer = 0.0  

var current_direction = 0.0  

func animation_player():
	match player_state:
		state.IDLE:
			animated_sprite.play("idle")
		state.RUNNING:
			animated_sprite.play("run")
		state.ROLLING:
			animated_sprite.play("roll")
		state.JUMPING:
			animated_sprite.play("in_the_air")
		state.DASHING:
			animated_sprite.play("dash")

func get_input():
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION)
		current_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	get_input()
	handle_dashing(delta)
	handle_rolling(delta)
	handle_jumping()
	update_state()
	update_cooldowns(delta)

	
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true
	
	animation_player()
	move_and_slide()

func handle_dashing(delta):
	if is_dashing:
		dash_time -= delta
		if dash_time <= 0:
			is_dashing = false
			player_state = state.IDLE
		else:
			velocity.x = current_direction * DASH_VELOCITY
	
	if Input.is_action_just_pressed("dash") and can_dash and player_state != state.ROLLING:
		start_dash()

func handle_rolling(delta):
	if is_rolling:
		roll_time -= delta
		if roll_time <= 0:
			is_rolling = false
			player_state = state.IDLE
		else:
			velocity.x = current_direction * ROLL_VELOCITY
	
	if Input.is_action_just_pressed("shift") and can_roll and is_on_floor():
		start_roll()

func handle_jumping():
	if is_on_floor() and player_state != state.ROLLING and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		player_state = state.JUMPING

func update_state():
	if velocity.x == 0 and player_state != state.ROLLING and not is_dashing:
		player_state = state.IDLE
	elif velocity.x != 0 and is_on_floor() and player_state != state.ROLLING and not is_dashing:
		player_state = state.RUNNING
	elif not is_on_floor():
		player_state = state.JUMPING

func start_dash():
	is_dashing = true
	dash_time = DASH_DURATION
	can_dash = false
	dash_cooldown_timer = DASH_COOLDOWN  
	player_state = state.DASHING

func start_roll():
	is_rolling = true
	roll_time = ROLL_DURATION
	can_roll = false
	roll_cooldown_timer = ROLL_COOLDOWN
	player_state = state.ROLLING

func update_cooldowns(delta):

	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true  

	if not can_roll:
		roll_cooldown_timer -= delta
		if roll_cooldown_timer <= 0:
			can_roll = true  

func _on_animated_sprite_2d_animation_finished():
	player_state = state.IDLE



#func move_player(direction, distance):
		#velocity.x = SPEED * direction * distance
#func basic_controlls():
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	#var direction = Input.get_axis("move_left", "move_right")
	#if direction > 0:
		#animated_sprite.play("run")
		#animated_sprite.flip_h = false
	#elif direction < 0:
		#animated_sprite.play("run")
		#animated_sprite.flip_h = true
	#elif direction == 0:
		#animated_sprite.play("idle")
	#if not is_on_floor():
		#animated_sprite.play("in_the_air")
	#move_player(direction, 1)
#
##rolling test
#func roll():
	#var timer = 60
	#animated_sprite.play("roll")
	#while timer > 0:
		#move_player(1, 5)
		#timer -= 1
#
#func _physics_process(delta):
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y += gravity * delta
	#basic_controlls()
	#
	## testing rolling
	#if Input.is_action_just_pressed("shift"):
		#var timer = 60
		#animated_sprite.play("roll")
		#while timer > 0:
			#move_player(1, 5)
			#timer -= 1
	#
	#if velocity.x == 0:
		#
