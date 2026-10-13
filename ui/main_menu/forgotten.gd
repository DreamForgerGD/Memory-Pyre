extends Node2D
## «Забытый» на фоне меню: еле заметно покачивается, глаза то гаснут, то проступают.
## Глаза — дочерний узел Eyes.

@export var sway_amount: float = 1.5
@export var sway_speed: float = 0.35
@export var eyes_min_alpha: float = 0.0
@export var eyes_max_alpha: float = 0.85

@onready var _eyes: Node2D = $Eyes

var _phase := 0.0
var _eyes_phase := 0.0
var _base_x := 0.0


func _ready() -> void:
	_phase = randf() * TAU
	_eyes_phase = randf() * TAU
	_base_x = position.x


func _process(delta: float) -> void:
	_phase += delta * sway_speed
	_eyes_phase += delta * sway_speed * 0.6
	position.x = _base_x + sin(_phase) * sway_amount
	# Глаза большую часть времени почти не видны и иногда медленно проступают.
	var k := pow((sin(_eyes_phase) + 1.0) * 0.5, 3.0)
	_eyes.modulate.a = lerpf(eyes_min_alpha, eyes_max_alpha, k)
