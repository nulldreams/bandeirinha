extends Node2D

var shake_amount = 1.0
var shaking = false


func _process(delta):
	if shaking:
		$Sprite.offset = Vector2(rand_range(-1.0, 1.0) * shake_amount, rand_range(-1.0, 1.0) * shake_amount)
	else:
		$Sprite.offset = Vector2.ZERO
		
func _on_ShakingTimer_timeout():
	shaking = false


func _on_Area2D_body_entered(body):
	$ShakingTimer.start()
	shaking = true
