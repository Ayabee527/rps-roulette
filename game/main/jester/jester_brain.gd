class_name JesterBrain
extends Node

signal hurt()

const FACES = {
	"DEFAULT": ["res://assets/textures/face.png"],
	"SMUG": ["res://assets/textures/face2.png", "res://assets/textures/face4.png"],
	"BRUH": ["res://assets/textures/face7.png"],
	"HURT": ["res://assets/textures/face9.png", "res://assets/textures/face10.png", "res://assets/textures/face8.png"],
	"DEAD": ["res://assets/textures/face6.png"],
	"UPSET": ["res://assets/textures/face3.png", "res://assets/textures/face5.png"],
	"LIZARD": ["res://assets/textures/lizard.png"],
	"SNAKE": ["res://assets/textures/snake.png"],
	"ELEPHANT": ["res://assets/textures/elephant.png"]
}

@export var revolver: Revolver
@export var game_manager: GameManager
@export var jester_window: Window

@export var face: TextureRect
@export var hurt_timer: Timer
@export var hurt_sound: AudioStreamPlayer

var marked_for_death: bool = false

func _ready() -> void:
	game_manager.jester_lost.connect(on_jester_lost)
	game_manager.player_lost.connect(on_player_lost)
	game_manager.draw.connect(on_draw)
	
	revolver.cocked.connect(on_revolver_cocked)
	revolver.spin_finished.connect(on_revolver_spun)
	revolver.shot.connect(on_revolver_shot)
	revolver.blanked.connect(on_blank)
	switch_face("DEFAULT")

func switch_face(type: String, delay: float = 0.0) -> void:
	if delay > 0.0:
		face.hide()
		await get_tree().create_timer(delay, false).timeout
	face.show()
	if FACES.has(type.to_upper()):
		face.texture = load(
			FACES[type.to_upper()].pick_random()
		)

func on_revolver_spun() -> void:
	marked_for_death = false
	var choices = [game_manager.LIZARD]
	game_manager.jester_choice = choices.pick_random()

func on_revolver_cocked() -> void:
	marked_for_death = false
	print("a")
	var choices = [game_manager.LIZARD]
	game_manager.jester_choice = choices.pick_random()

func on_jester_lost() -> void:
	marked_for_death = true

func on_player_lost() -> void:
	switch_face("SMUG", 0.1)

func on_draw() -> void:
	switch_face("BRUH", 0.1)

func on_blank() -> void:
	marked_for_death = false
	switch_face("DEFAULT", 0.1)

func on_revolver_shot() -> void:
	if marked_for_death:
		shoot()
	marked_for_death = false

func shoot() -> void:
	hurt.emit()
	hurt_sound.play()
	switch_face("HURT")
	hurt_timer.start()

func lose() -> void:
	pass


func _on_hurt_timer_timeout() -> void:
	switch_face("UPSET", 0.1)


func _on_confirm_pressed() -> void:
	match game_manager.jester_choice:
		game_manager.LIZARD:
			switch_face("LIZARD", 0.1)
		game_manager.SNAKE:
			switch_face("SNAKE", 0.1)
		game_manager.ELEPHANT:
			switch_face("ELEPHANT", 0.1)
