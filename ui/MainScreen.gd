extends Node2D

func _ready():
	$Play.grab_focus()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().quit()

func _on_Exit_button_down():
	get_tree().quit()

func _on_Play_button_down():
	get_tree().change_scene("res://levels/Level1.tscn")

func _on_Help_button_down():
	get_tree().change_scene("res://ui/Help.tscn")
