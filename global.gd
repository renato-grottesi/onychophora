extends Node

func _ready():
	var music_file = "res://sounds/onychophora.ogg"
	var stream = AudioStream.new()
	var music_player = AudioStreamPlayer.new()
	if File.new().file_exists(music_file):
		var music = load(music_file)
		music_player.stream = music
		music_player.play()
		add_child(music_player)