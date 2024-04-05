class_name GameManager
extends Resource

enum {LIZARD, SNAKE, ELEPHANT}

@export var max_jester_lives: int = 3
@export var max_player_lives: int = 3

signal draw()
signal jester_lost()
signal player_lost()
signal jester_died()
signal player_died()

var jester_choice: int = -1
var player_choice: int = -1

var jester_lives: int:
	set(new_lives):
		jester_lives = new_lives
		if jester_lives == 0:
			jester_died.emit()
var player_lives: int:
	set(new_lives):
		player_lives = new_lives
		if player_lives == 0:
			player_died.emit()

func reset_jester_lives() -> void:
	jester_lives = max_jester_lives

func reset_player_lives() -> void:
	player_lives = max_player_lives

func check() -> void:
	if not check_draw():
		check_win()

func check_draw() -> bool:
	var drawn: bool = false
	
	if jester_choice == player_choice:
		drawn = true
	
	if drawn:
		draw.emit()
	return drawn

func check_win() -> bool:
	var player_win: bool = true
	
	match player_choice:
		LIZARD:
			if jester_choice == SNAKE:
				player_win = false
		SNAKE:
			if jester_choice == ELEPHANT:
				player_win = false
		ELEPHANT:
			if jester_choice == LIZARD:
				player_win = false
	
	if player_win:
		jester_lost.emit()
		jester_lives -= 1
	else:
		player_lost.emit()
		player_lives -= 1
	return player_win
