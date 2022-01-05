extends Node3D

var is_top_view = false

func _ready():
	set_process(true)

func _process(_delta):
	if Input.is_action_pressed("camera_rotation_right"):
		$Pivot.rotation.y += 0.02
	elif Input.is_action_pressed("camera_rotation_left"):
		$Pivot.rotation.y -= 0.02
	elif Input.is_action_just_released("top_view"):
		toggle_top_view()

func toggle_top_view():
	is_top_view = not is_top_view
	$Pivot/FreeCamera.current = not is_top_view
	$TopView.current = is_top_view

func _on_Board_new_turn():
	var message = "Current turn: "
	if GameState.is_whites_turn:
		message += "Whites"
	else:
		message += "Blacks"
	$UI/Turn.text = message
	$UI/State.text = ""

func _on_Board_check():
	$UI/State.text = "Check!"
