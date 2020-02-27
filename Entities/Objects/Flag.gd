extends Area2D

export var flag_team = "B"
var flag_position = position

func _physics_process(delta):
	position += flag_position

func _on_Flag_body_entered(body):
	if body.type == "player" and body.player_team != flag_team:
		get_tree().queue_delete(self)
		body.catch_flag()
