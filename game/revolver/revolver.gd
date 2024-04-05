class_name Revolver
extends Sprite2D

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

@export_group("Outer Dependencies")
@export var revolver_window: Window

@export_group("Inner Dependencies")
@export var fire_sound: AudioStreamPlayer
@export var click_sound: AudioStreamPlayer
@export var cock_sound: AudioStreamPlayer
@export var spin_sound: AudioStreamPlayer

var chambers_left: int = 6:
	set = set_chambers_left
var current_chamber: int = 0

var live_chambers: Array[int] = [0, 1, 2, 3, 4, 5]

func _ready() -> void:
	pass
	
	#spin()
	#await get_tree().create_timer(4.0).timeout
	#for i: int in range(6):
		#await get_tree().create_timer(1.0).timeout
		#fire()

func _process(delta: float) -> void:
	pass

func set_chambers_left(new_chambers: int) -> void:
	chambers_left = new_chambers
	texture = load(SPRITES[chambers_left])

func spin() -> void:
	spin_started.emit()
	chambers_left = 6
	rotation_degrees = 0
	spin_sound.play()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(
		self, "rotation_degrees", 0.0, 3.5
	).from(3600.0)
	tween.finished.connect(
		func():
			rotation_degrees = 0
			current_chamber = 0
			spin_finished.emit()
			cock_sound.play()
	)

func cock() -> void:
	if chambers_left > 0:
		var tween = create_tween()
		tween.tween_property(
			self, "rotation_degrees", rotation_degrees - (360.0 / 6.0), 0.15
		).from(rotation_degrees)
		tween.finished.connect(
			func():
				current_chamber += 1
				cocked.emit(current_chamber)
				cock_sound.play()
		)
	else:
		spin()

func fire() -> void:
	chambers_left -= 1
	if live_chambers.has(current_chamber):
		fire_sound.play()
		shake_window(24)
		shot.emit()
		live_chambers.erase(current_chamber)
	else:
		click_sound.play()
		shake_window(12)
		blanked.emit()
	await get_tree().create_timer(0.5, false).timeout
	cock()

func shake_window(strength: int = 24) -> void:
	var screen_center: Vector2i = (
		DisplayServer.screen_get_usable_rect().size / 2
	)
	var shake_offset = Vector2i(
		Vector2.from_angle(TAU * randf()) * strength
	)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		revolver_window, "position", screen_center - (revolver_window.size / 2),
		0.5
	).from(revolver_window.position + shake_offset)
	tween.play()
