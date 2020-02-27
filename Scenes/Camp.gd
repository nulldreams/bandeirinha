extends Area2D

signal team_make_a_point

enum Team { A, B }
export(Team) var team = Team.A

func _process(delta):
	if Engine.editor_hint:
		if team == Team.B:
			$CollisionShape2D.position.x = 342
			$CollisionShape2D.position.y = 72
		else:
			$CollisionShape2D.position.x = 184
			$CollisionShape2D.position.y = 72


func _on_Camp_body_entered(body):
	if body.type == 'player' and body.team == team and body.carry_flag:
		body.drop_flag()
		emit_signal("team_make_a_point", body.team)


func _on_Camp2_body_entered(body):
	if body.type == 'player' and body.team == team and body.carry_flag:
		body.drop_flag()
		emit_signal("team_make_a_point", body.team)
