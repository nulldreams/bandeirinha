extends Camera2D

export var shake_power = 4
export var shake_time = 0.4
var isShake = false
var curPos
var elapsedtime = 0

func _ready():
	randomize()
	curPos = offset

func _process(delta):
	if isShake:
		shake(delta)    

func _input(event):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and not isShake:
		elapsedtime = 0
		isShake = true
		
func start_shaking():
	elapsedtime = 0
	$ShakingTimer.start()
	isShake = true
	
func stop_shaking():
	elapsedtime = 0
	isShake = false

func shake(delta):
	if elapsedtime<shake_time:
		offset =  Vector2(randf(), randf()) * shake_power
		elapsedtime += delta
	else:
		isShake = false
		elapsedtime = 0
		offset = curPos   


func _on_ShakingTimer_timeout():
	stop_shaking()
