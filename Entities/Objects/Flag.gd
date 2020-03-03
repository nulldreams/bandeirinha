extends Area2D

enum Team { A, B }
export(Team) var team = Team.A
var initial_position = position

var flag_position = position

signal update_team_points

func _physics_process(delta):
	position += flag_position

func _on_Flag_body_entered(body):
	if body.type == "player" and body.team != team:
		$".".visible = false
		body.catch_flag()

func _ready():
	var camp_A = get_tree().get_root().get_node("Main/World/TileMap/Camp")
	var camp_B = get_tree().get_root().get_node("Main/World/TileMap/Camp2")
	var player = get_tree().get_root().get_node("Main/World/Player")
	
	player.connect("player_was_freeze", self, "reset_flag_when_freeze")
	camp_A.connect("team_make_a_point", self, "reset_flag")
	camp_B.connect("team_make_a_point", self, "reset_flag")

func reset_flag(team_point):
	$".".visible = true
	emit_signal("update_team_points", team)

func reset_flag_when_freeze(team_point):
	$".".visible = true
