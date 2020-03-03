extends Control

var _player_name = ""
var _player_team = null


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name, _player_team)
	_load_game()


func _on_PlayerName_text_changed(new_text):
	_player_name = new_text


func _on_CreateButton_pressed():
	get_tree().change_scene("res://Scenes/Game.tscn")
#	if _player_name == "":
#		return
#	Network.create_server(_player_name, _player_team)
#	_load_game()

func _load_game():
	get_tree().change_scene("res://Scenes/Game.tscn")


func _on_Menu_ready():
	$Teams.add_item("A")
	$Teams.add_item("B")


func _on_Teams_item_selected(id):
	_player_team = id
