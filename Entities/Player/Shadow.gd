extends AnimatedSprite

var target
export(NodePath) var targetPath

func _ready():
	target = get_node(targetPath)
	print(target.position.y + (13))
	$".".position.y = target.position.y + (13)
