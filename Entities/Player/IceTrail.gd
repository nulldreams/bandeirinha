extends Line2D

var target
var point
export(NodePath) var targetPath
export var trailLength = 0

func _ready():
	target = get_node(targetPath)

func _physics_process(delta):
	global_position = Vector2.ZERO
	global_rotation = 0
	point = target.global_position
	point.y += 13
	add_point(point)
	print(get_point_count(), " ", trailLength)
	while get_point_count() > trailLength:
		remove_point(0)
