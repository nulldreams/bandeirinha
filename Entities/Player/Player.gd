extends KinematicBody2D

export var player_speed = 75
export var type = "player"
export var player_name = "Igor"

signal set_player_info
signal players_collides

enum Team { A, B }
export(Team) var team = Team.A

enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }
slave var slave_position = Vector2()
slave var slave_movement = MoveDirection.NONE

var MAX_SPEED = 500
var ACCELERATION = 2000
var motion = Vector2()

var last_direction = Vector2(1, 0)
var last_frame

enum {
	STATE_IDLE,
	STATE_RUNNING,
	STATE_DASHING,
	STATE_FLAG,
	STATE_FREEZE
}

var flag = false
var carry_flag = false

var state = STATE_IDLE
var previous_state = state

func _ready():
	emit_signal("set_player_info", player_name, team)

func state_machine(direction):
	match state:
		STATE_IDLE:
			idle_player()
		STATE_RUNNING:
			move_player(direction)
		STATE_FREEZE:
			$FootDust.emitting = false
			$Sprite.playing = false
			$Sprite.modulate = Color(0, 0, 1, 1)

func _input(event):
	if event.is_action_pressed("player_dash") and state == STATE_RUNNING:
		dash_player()
	elif event.is_action_pressed("freeze"):
		if state == STATE_FREEZE:
			$Sprite.modulate = Color(1, 1, 1, 1)
			state = STATE_IDLE
		else:
			state = STATE_FREEZE
			print(state)

func dash_player():
	$CollisionShape2D.disabled = true
	player_speed = 300
	$DashDuration.start()
	
func _physics_process(delta):
	var direction: Vector2
	last_frame = $Sprite.frame
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
		
	var movement = player_speed * direction * delta
	animates_player(direction)
	state_machine(direction)
	previous_state = state
	if state != STATE_FREEZE:
		move_and_collide(movement)
	rset_unreliable('slave_position', position)
	rset('slave_movement', direction)

func animates_player(direction: Vector2):
	if direction != Vector2.ZERO and state != STATE_FREEZE:
		state = STATE_RUNNING
	
	if player_speed >= 300 and state != STATE_FREEZE:
		state = STATE_DASHING
	
	if direction == Vector2.ZERO and !flag and state != STATE_FREEZE:
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
	if carry_flag:
		$Sprite.play("idle_with_flag")
	else:
		$Sprite.play("idle")

func move_player(direction: Vector2):
	get_animation_direction(direction)
	$FootDust.emitting = true
	last_direction = direction
	if carry_flag:
		$Sprite.play("run_with_flag")
	else:
		$Sprite.play("run")
	$FootDust.position.x = $Sprite.position.x
	
func catch_flag():
	carry_flag = true

func drop_flag():
	carry_flag = false

func freeze_player():
	$Sprite.modulate = Color(0, 0, 1)

func _on_ColisionArea_body_entered(body):
	if body.team != team:
		emit_signal("players_collides", body.team)

func _on_GhostTimer_timeout():
	if state == STATE_DASHING:
		var ghost_player = preload("res://Entities/Player/Ghost.tscn").instance()
		get_parent().add_child(ghost_player)
		ghost_player.position = position
		ghost_player.z_index = $Sprite.z_index
		ghost_player.texture = $Sprite.frames.get_frame($Sprite.animation, $Sprite.frame)
		ghost_player.flip_h = $Sprite.flip_h


func _on_DashDuration_timeout():
	player_speed = 75
	state = previous_state
	$CollisionShape2D.disabled = false
