extends PanelContainer

@export var game_manager: GameManager

@export_group("Dependencies")
@export_subgroup("Windows")
@export var jester_window: Window
@export var revolver_window: Window

@export_subgroup("Player UI")
@export var choice_buttons: Array[Button]
@export var lizard_button: Button
@export var snake_button: Button
@export var elephant_button: Button
@export var confirm_button: Button

@export_subgroup("Miscellaneous")
@export var revolver: Revolver
@export var jester_brain: JesterBrain
@export var suspense_timer: Timer

var player_marked_for_death: bool = false

var screen_index: int = -1
var screen_size: Rect2i
var screen_center: Vector2i

var window: Window

func _ready() -> void:
	window = get_window()
	
	screen_index = DisplayServer.get_primary_screen()
	screen_size = DisplayServer.screen_get_usable_rect(screen_index)
	screen_center = screen_size.size / 2
	
	game_manager.player_lost.connect(on_player_lost)
	game_manager.draw.connect(on_draw)
	
	revolver.spin_finished.connect(on_revolver_spun)
	revolver.cocked.connect(on_revolver_cocked)
	revolver.shot.connect(on_revolver_shot)
	
	center_revolver()
	tween_windows_to_center()
	
	revolver.spin()

func center_revolver() -> void:
	revolver_window.show()
	revolver_window.position = screen_center
	revolver_window.position -= revolver_window.size / 2

func tween_windows_to_center() -> void:
	tween_player_window_to_center()
	jester_window.show()
	tween_jester_window_to_center()

func tween_player_window_to_center() -> void:
	window.position = get_player_rest_spot()
	window.position.y = -window.size.y
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(
		window, "position", get_player_rest_spot(), 3.0
	).from_current()
	tween.play()

func tween_jester_window_to_center() -> void:
	jester_window.position = get_jester_rest_spot()
	jester_window.position.y = DisplayServer.screen_get_size(screen_index).y
	jester_window.position.y += jester_window.size.y
	jester_window.position.y += jester_window.size.y / 2
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(
		jester_window, "position", get_jester_rest_spot(), 3.0
	).from_current()
	tween.play()

func get_player_rest_spot() -> Vector2i:
	var rest_position = screen_center
	rest_position.y -= window.size.y / 2
	rest_position.x += window.size.y / 2
	
	return rest_position

func get_jester_rest_spot() -> Vector2i:
	var rest_position: Vector2i = screen_center
	
	rest_position = screen_center
	rest_position.y -= jester_window.size.y / 2
	rest_position.x -= jester_window.size.x
	rest_position.x -= jester_window.size.x / 2
	
	return rest_position

func reset_other_choices(chosen_button: Button) -> void:
	for button: Button in choice_buttons:
		if button != chosen_button:
			button.button_pressed = false
	
	confirm_button.show()

func _on_liz_pressed() -> void:
	game_manager.player_choice = game_manager.LIZARD
	reset_other_choices(lizard_button)

func _on_snek_pressed() -> void:
	game_manager.player_choice = game_manager.SNAKE
	reset_other_choices(snake_button)

func _on_eleph_pressed() -> void:
	game_manager.player_choice = game_manager.ELEPHANT
	reset_other_choices(elephant_button)

func shake_jester_window(strength: int = 32) -> void:
	var shake_offset = Vector2i(
		Vector2.from_angle(TAU * randf()) * strength
	)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		jester_window, "position", get_jester_rest_spot(),
		0.5
	).from(jester_window.position + shake_offset)
	tween.play()

func shake_player_window(strength: int = 32) -> void:
	var shake_offset = Vector2i(
		Vector2.from_angle(TAU * randf()) * strength
	)
	var window := get_window()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		window, "position", get_player_rest_spot(),
		0.5
	).from(window.position + shake_offset)
	tween.play()

func _on_confirm_pressed() -> void:
	suspense_timer.start()

func on_draw() -> void:
	pass

func on_player_lost() -> void:
	player_marked_for_death = true

func on_revolver_shot() -> void:
	if player_marked_for_death:
		shake_player_window()

func on_revolver_cocked() -> void:
	player_marked_for_death = false

func on_revolver_spun() -> void:
	player_marked_for_death = false

func _on_suspense_timer_timeout() -> void:
	if not game_manager.check_draw():
		game_manager.check_win()
		revolver.fire()


func _on_jester_brain_hurt() -> void:
	shake_jester_window()
