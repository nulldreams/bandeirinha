extends AnimatedSprite

var target
export(NodePath) var targetPath

func _ready():
	target = get_node(targetPath)
	$".".position.y = target.position.y + (13)
