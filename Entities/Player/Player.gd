extends KinematicBody2D

export var player_speed = 75
export var type = "player"
export var player_name = "Igor"
export var scene_master = false

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

enum {
	STATE_IDLE,
	STATE_RUNNING,
	STATE_DASHING,
	STATE_FLAG
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

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var target = $RayCast2D.get_collider()
		if target != null:
			print(target)

func _physics_process(delta):
	# check if player is the master
	if is_network_master():
		scene_master = true
		var direction: Vector2
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		if abs(direction.x) == 1 and abs(direction.y) == 1:
			direction = direction.normalized()
			
		var movement = player_speed * direction * delta
		animates_player(direction)
		state_machine(direction)
		previous_state = state
		move_and_collide(movement)
		rset_unreliable('slave_position', position)
		rset('slave_movement', direction)
	else:
		animates_player(slave_movement)
		state_machine(slave_movement)
		previous_state = state
		move_and_collide(slave_movement)
		position = slave_position
	
	$Camera2D.current = scene_master
	
	if get_tree().is_network_server():
		Network.update_position(int(name), position)

func animates_player(direction: Vector2):
	if direction != Vector2.ZERO:
		state = STATE_RUNNING
	
	if player_speed >= 300:
		state = STATE_DASHING
	
	if direction == Vector2.ZERO and !flag:
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
	if carry_flag:
		$Sprite.play("idle_with_flag")
	else:
		$Sprite.play("idle")

func move_player(direction: Vector2):
	get_animation_direction(direction)
	last_direction = direction
	if carry_flag:
		$Sprite.play("run_with_flag")
	else:
		$Sprite.play("run")
	
func catch_flag():
	carry_flag = true

func drop_flag():
	carry_flag = false

func freeze_player():
	$Sprite.modulate = Color(0, 0, 1)

func _on_ColisionArea_body_entered(body):
	if body.team != team:
		emit_signal("players_collides", body.team)

func init(nickname, start_position):
	$Nickname.text = nickname
	global_position = start_position
