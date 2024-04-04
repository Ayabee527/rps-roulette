class_name Chamber
extends Sprite2D

@export var chamber_window: Window

const SPRITES = {
	6: "res://assets/textures/gunchamber.png",
	5: "res://assets/textures/gunchamber-1.png",
	4: "res://assets/textures/gunchamber-2.png",
	3: "res://assets/textures/gunchamber-3.png",
	2: "res://assets/textures/gunchamber-4.png",
	1: "res://assets/textures/gunchamber-5.png",
	0: "res://assets/textures/gunchamber-6.png",
}

signal spin_started()
signal spin_finished()
signal cocked(chamber: int)
signal blanked()
signal shot()

@export var rotation_speed: float = 0.0

var chambers_left: int = 6:
	set = set_chambers_left
var current_chamber: int = 0

var live_chambers: Array[int] = []

func _ready() -> void:
	pass
	
	#spin()
	#await get_tree().create_timer(5.5).timeout
	#for i: int in range(6):
		#await get_tree().create_timer(1.5).timeout
		#fire()

func _process(delta: float) -> void:
	rotation_degrees += rotation_speed * delta

func set_chambers_left(new_chambers: int) -> void:
	chambers_left = new_chambers
	texture = load(SPRITES[chambers_left])

func spin() -> void:
	chambers_left = 6
	rotation_degrees = 0
	var tween = create_tween()
	#tween.tween_property(
		#self, "rotation_speed", 0.0, 5.0
	#).from(720.0)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(
		self, "rotation_degrees", 0.0, 5.0
	).from(3600.0)
	tween.finished.connect(
		func():
			rotation_degrees = 0
			current_chamber = 0
	)

func cock() -> void:
	rotation_speed = 0.0
	if chambers_left > 0:
		var tween = create_tween()
		tween.tween_property(
			self, "rotation_degrees", rotation_degrees - (360.0 / 6.0), 0.15
		).from(rotation_degrees)
		tween.finished.connect(
			func():
				current_chamber += 1
		)
	else:
		spin()

func fire() -> void:
	chambers_left -= 1
	if live_chambers.has(current_chamber):
		shot.emit()
		live_chambers.erase(current_chamber)
	else:
		blanked.emit()
	shake_window()
	await get_tree().create_timer(1.0, false).timeout
	cock()

func shake_window() -> void:
	var screen_center: Vector2i = (
		DisplayServer.screen_get_usable_rect().size / 2
	)
	var shake_offset = Vector2i(
		Vector2.from_angle(TAU * randf()) * 24.0
	)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		chamber_window, "position", screen_center - (chamber_window.size / 2),
		0.5
	).from(chamber_window.position + shake_offset)
	tween.play()
