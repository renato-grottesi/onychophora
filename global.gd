extends Node

var music_player
var music = preload("res://sounds/onychophora.ogg")

func _ready():
	music_player = AudioStreamPlayer2D.new()
	music_player.stream = music
	music_player.play()
	add_child(music_player)

func _process(delta):
	if not(music_player.playing):
		music_player.play()