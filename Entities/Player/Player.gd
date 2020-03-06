extends KinematicBody2D

# rafact
var MAX_SPEED = 170
var MAX_DASH_IMPULSE = 20
var DASH_IMPULSE = 0
var ACCELERATION = 500
var motion = Vector2.ZERO
# rafact

export var player_speed = 75
export var type = "player"
export var player_name = "Igor"

signal set_player_info
signal players_collides
signal player_was_freeze

enum Team { A, B }
export(Team) var team = Team.A

enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }
slave var slave_position = Vector2()
slave var slave_movement = MoveDirection.NONE

var last_direction = Vector2(1, 0)
var last_frame = 0
var shadow_before_jump = Vector2.ZERO

enum {
	STATE_IDLE,
	STATE_RUNNING,
	STATE_DASHING,
	STATE_FLAG,
	STATE_FREEZE,
	STATE_JUMPING
}

var flag = false
var carry_flag = false

var state = STATE_IDLE
var previous_state = state

# y jump
var z_speed = 5
var gravity = 1
var z_floor = 0
var z = 0
var jump_height = 10
var jumping = false
var landed = true
# y jump

func _ready():
	emit_signal("set_player_info", player_name, team)
	$Shadow.play("shadowing")

func state_machine(direction):
	match state:
		STATE_IDLE:
			idle_player()
		STATE_RUNNING:
			move_player(direction)
		STATE_FREEZE:
			freeze_player()
		STATE_JUMPING:
			jumping()

func _input(event):
	if event.is_action_pressed("jump") and state != STATE_FREEZE and state != STATE_JUMPING:
		$JumpTimer.start()
		jumping = true
	elif event.is_action_pressed("player_dash") and state == STATE_RUNNING:
		dash_player()
	elif event.is_action_pressed("freeze"):
		if state == STATE_FREEZE:
			$IceTrail.visible = false
			state = STATE_IDLE
		else:
			state = STATE_FREEZE
#	z_index = 0

func dash_player():
	$CollisionShape2D.disabled = true
	DASH_IMPULSE = MAX_DASH_IMPULSE
	$DashDuration.start()
	
func jumping():
	$CollisionShape2D.disabled = true
	if carry_flag:
		$Sprite.play("jumping_with_flag")
		$Shadow.play("shadow_jumping")
	else:
		$Sprite.play("jumping")
		$Shadow.play("shadow_jumping")

func _on_JumpTimer_timeout():
	$CollisionShape2D.disabled = false
	$Shadow.play("shadowing")
	$LandingDust.emitting = true
	$Camera2D.start_shaking()
	jumping = false
	state = STATE_RUNNING
	
func _physics_process(delta):
	if jumping and z_index <= jump_height:
		z_index += z_speed
		position.y -= z_speed
	elif !jumping and z_index > z_floor:
		position.y += z_speed
		z_index -= z_speed
	$Shadow.position.y = $Sprite.position.y + (z_index + 13)
	$LandingDust.position = $Shadow.position
	
	last_frame = $Sprite.frame
	var axis = Vector2.ZERO 
	if state != STATE_FREEZE:
		axis = get_input_axis()
		
	get_animation_direction(axis)
	if axis == Vector2.ZERO:
		apply_friction(ACCELERATION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta)
			
	animates_player(motion)
	state_machine(motion)
	previous_state = state
	motion = move_and_slide(motion)

func animates_player(direction: Vector2):
	if jumping:
		state = STATE_JUMPING
	if direction != Vector2.ZERO and state != STATE_FREEZE and !jumping:
		state = STATE_RUNNING
	if DASH_IMPULSE > 0 and state != STATE_FREEZE and !jumping:
		state = STATE_DASHING
	if direction == Vector2.ZERO and !flag and state != STATE_FREEZE and !jumping:
		state = STATE_IDLE

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.x <= -0.707:
		$Sprite.flip_h = true
		last_direction = Vector2(-1, 0)
	elif norm_direction.x >= 0.707:
		$Sprite.flip_h = false
		last_direction = Vector2(1, 0)
		
func idle_player():
	$FootDust.emitting = false
	$Sprite.scale.y = 1
	if carry_flag:
		$Sprite.play("idle_with_flag")
	else:
		$Sprite.play("idle")
		
	$Sprite.frame = last_frame

func move_player(direction: Vector2):
	$FootDust.emitting = true
	last_direction = direction
	if carry_flag:
		$Sprite.play("run_with_flag")
	else:
		$Sprite.play("run")
	$FootDust.position.x = $Sprite.position.x

func _rand(_min, _max):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf_range(_min, _max)

func catch_flag():
	carry_flag = true

func drop_flag():
	carry_flag = false

func freeze_player():
	$IceTrail.visible = true
	$IceTrail.position.y = $Sprite.position.y
#	if "_with_flag" in $Sprite.animation:
#		$Sprite.play($Sprite.animation.replace("_with_flag", "_freeze"))
#
#	$Sprite.play($Sprite.animation + "_freeze")
	$Sprite.play("idle_freeze")
	$Sprite.frame = last_frame
	$LandingDust.emitting = false
#	$Sprite.playing = false
	drop_flag()
	emit_signal("player_was_freeze", true)

func _on_ColisionArea_body_entered(body):
	pass
#	if body.team != team:
#		emit_signal("players_collides", body.team)

func _on_GhostTimer_timeout():
	if state == STATE_DASHING:
		var ghost_player = preload("res://Entities/Player/Ghost.tscn").instance()
		get_parent().add_child(ghost_player)
		ghost_player.position = position
		ghost_player.z_index = $Sprite.z_index
		ghost_player.texture = $Sprite.frames.get_frame($Sprite.animation, $Sprite.frame)
		ghost_player.flip_h = $Sprite.flip_h

func _on_DashDuration_timeout():
	DASH_IMPULSE = 0
	state = previous_state
	$CollisionShape2D.disabled = false

# REFACT MOVEMENT
func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return axis.normalized()
	
func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO
		
func apply_movement(acceleration):
	motion += acceleration
	if state == STATE_DASHING:
		motion += motion.clamped(DASH_IMPULSE)
	else:
		motion = motion.clamped(MAX_SPEED)
# REFACT MOVEMENT
