extends Node2D

export var next_level = 0
export var head = Vector2(3,1)
#export var sections = [Vector2(1,1), Vector2(2,1), Vector2(3,1)]

func _ready():
	$Worm.set_sections_from_head(head)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			get_tree().change_scene("res://ui/MainScreen.tscn")
		if event.pressed and event.scancode == KEY_R:
			get_tree().reload_current_scene()

func _on_Worm_win():
	if next_level==0:
		get_tree().change_scene("res://ui/Victory.tscn")
	else:
		get_tree().change_scene("res://levels/Level"+str(next_level)+".tscn")

func _on_Worm_lose():
	get_tree().reload_current_scene()