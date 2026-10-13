extends Node2D
## Свеча: мерцание пламени, света и ореола.
## Дочерние узлы: Flame (пламя), Light (PointLight2D — освещает дерево и землю),
## Glow (необязательный Sprite2D — мягкий тёплый ореол поверх).

@export var base_energy: float = 1.6
@export var flicker_strength: float = 0.25
@export var flicker_speed: float = 6.0

@onready var _flame: Node2D = $Flame
@onready var _light: PointLight2D = $Light
@onready var _glow: CanvasItem = get_node_or_null("Glow")

var _noise := FastNoiseLite.new()
var _t := 0.0
var _base_scale := 1.0
var _glow_alpha := 1.0


func _ready() -> void:
	_noise.seed = randi()
	_noise.frequency = 0.8
	_base_scale = _light.texture_scale
	if _glow:
		_glow_alpha = _glow.modulate.a


func _process(delta: float) -> void:
	_t += delta * flicker_speed
	var n := _noise.get_noise_1d(_t) # -1..1
	_light.energy = base_energy + n * flicker_strength
	_light.texture_scale = _base_scale * (1.0 + n * 0.04)
	_flame.scale = Vector2(1.0 - n * 0.1, 1.0 + n * 0.2)
	_flame.rotation = _noise.get_noise_1d(_t + 50.0) * 0.12
	if _glow:
		_glow.modulate.a = _glow_alpha * (1.0 + n * 0.25)
