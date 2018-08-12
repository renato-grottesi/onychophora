extends Node2D

func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene("res://ui/MainScreen.tscn")
