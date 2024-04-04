extends PanelContainer

@export var jester_window: Window

var screen_index: int = -1
var screen_size: Rect2i
var screen_center: Vector2i

func _ready() -> void:
	screen_index = DisplayServer.get_primary_screen()
	screen_size = DisplayServer.screen_get_usable_rect(screen_index)
	screen_center = screen_size.size / 2
	
	tween_windows_to_center()

func tween_windows_to_center() -> void:
	tween_player_window_to_center()
	jester_window.show()
	tween_jester_window_to_center()

func tween_player_window_to_center() -> void:
	var window := get_window()
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
	var window := get_window()
	
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
