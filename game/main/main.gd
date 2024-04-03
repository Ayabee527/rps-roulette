extends PanelContainer

@export var jester_window: Window

var screen_index: int = -1
var screen_size: Rect2i
var screen_center: Vector2i

func _ready() -> void:
	screen_index = DisplayServer.get_primary_screen()
	screen_size = DisplayServer.screen_get_usable_rect(screen_index)
	screen_center = screen_size.size / 2
	
	center_windows()

func center_windows() -> void:
	ready_player_window()
	ready_jester_window()

func ready_player_window() -> void:
	var window := get_window()
	
	window.position = screen_center
	window.position.y -= window.size.y / 2
	window.position.x += window.size.x / 4

func ready_jester_window() -> void:
	jester_window.position = screen_center
	jester_window.position.y -= jester_window.size.y / 2
	jester_window.position.x -= jester_window.size.x
	jester_window.position.x -= jester_window.size.x / 4
