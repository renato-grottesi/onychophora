extends Node2D

func _ready():
	$Play.grab_focus()
	OS.set_window_fullscreen(true)
	if OS.get_name() == "HTML5":
		$Exit.text = "FULLSCREEN"
		$Exit.rect_position = Vector2(0, $Exit.rect_position.y)
		$Exit.rect_size = Vector2(64, $Exit.rect_size.y)
		$Play.rect_position = Vector2(0, $Play.rect_position.y)
		$Play.rect_size = Vector2(64, $Play.rect_size.y)
		$Help.rect_position = Vector2(0, $Help.rect_position.y)
		$Help.rect_size = Vector2(64, $Help.rect_size.y)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()
		if event.pressed and event.scancode == KEY_F:
			OS.set_window_fullscreen(not OS.window_fullscreen)

func _on_Exit_button_down():
	if OS.get_name() == "HTML5":
		OS.set_window_fullscreen(not OS.window_fullscreen)
	else:
		get_tree().quit()

func _on_Play_button_down():
	get_tree().change_scene("res://levels/Level1.tscn")

func _on_Help_button_down():
	get_tree().change_scene("res://ui/Help.tscn")
