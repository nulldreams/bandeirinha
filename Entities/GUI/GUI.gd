extends CanvasLayer

var teams = {
	0: "A",
	1: "B"
}

func _ready():
	var player = get_tree().get_root().get_node("Main/World/Player")
	var flag_a = get_tree().get_root().get_node("Main/World/FlagA")
	var flag_b = get_tree().get_root().get_node("Main/World/FlagA")
	flag_a.connect("update_team_points", self, "update_team_points")
	player.connect("set_player_info", self, "set_player_info")

func set_player_info(name, team):
	$PanelLeft/Name.text = name

func update_team_points(team):
	if teams[team] == "A":
		$PanelMid2/PanelMid/TeamAPoints.text = str(int($PanelMid2/PanelMid/TeamAPoints.text) + 1)
	elif teams[team] == "B":
		$PanelMid2/PanelMid/TeamBPoints.text = str(int($PanelMid2/PanelMid/TeamBPoints.text) + 1)
