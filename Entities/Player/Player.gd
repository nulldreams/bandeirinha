extends KinematicBody2D

export var player_speed = 75
export var type = "player"
export var player_name = "Igor"

signal set_player_info

enum Team { A, B }
export(Team) var team = Team.A

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
