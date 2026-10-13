extends Node2D
## Главное меню: «Играть», «Настройки», «Выход».
## Фон — слои-заглушки в узле Background. Чтобы натянуть арт, замените
## Polygon2D в нужном слое на Sprite2D с текстурой — код от этого не зависит.

## Сцена, которая запускается по кнопке «Играть».
@export_file("*.tscn") var game_scene_path: String = "res://ui/stub/game_stub.tscn"
## Длительность затемнения при входе и выходе, сек.
@export var fade_time: float = 0.8

@onready var _play_button: Button = %PlayButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _selector: Control = %Selector
@onready var _settings_menu: Control = %SettingsMenu
@onready var _fader: ColorRect = %Fader

var _busy := false # идёт переход — ввод игнорируем
var _selector_t := 0.0


func _ready() -> void:
	GameSettings.load_settings()
	GameSettings.apply()

	for button: Button in [_play_button, _settings_button, _quit_button]:
		button.mouse_entered.connect(button.grab_focus)
	_play_button.pressed.connect(_on_play_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_settings_menu.closed.connect(_on_settings_closed)
	_settings_menu.hide()

	# Плавное появление из темноты.
	_fader.color.a = 1.0
	_fader.mouse_filter = Control.MOUSE_FILTER_STOP
	create_tween().tween_property(_fader, "color:a", 0.0, fade_time)\
		.finished.connect(func(): _fader.mouse_filter = Control.MOUSE_FILTER_IGNORE)

	# Ждём один кадр, чтобы контейнер расставил кнопки, и ставим огонёк сразу на место.
	await get_tree().process_frame
	_play_button.grab_focus()
	_update_selector(1.0)


func _process(delta: float) -> void:
	_update_selector(1.0 - exp(-delta * 18.0))
	# Лёгкое мерцание огонька-указателя.
	_selector_t += delta
	var flicker := 1.0 + sin(_selector_t * 11.0) * 0.06 + sin(_selector_t * 4.3) * 0.05
	_selector.scale = Vector2(1.0, flicker)


## Плавно подводит огонёк к кнопке, на которой фокус.
func _update_selector(weight: float) -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if not (focused is Button and focused.get_parent() == _play_button.get_parent()):
		_selector.visible = false
		return
	_selector.visible = true
	var target := Vector2(
		focused.global_position.x - _selector.size.x - 12.0,
		focused.global_position.y + (focused.size.y - _selector.size.y) * 0.5)
	_selector.global_position = _selector.global_position.lerp(target, weight)


func _on_play_pressed() -> void:
	if _busy:
		return
	if not ResourceLoader.exists(game_scene_path):
		push_error("Игровая сцена не найдена: %s" % game_scene_path)
		return
	_fade_out(func(): get_tree().change_scene_to_file(game_scene_path))


func _on_settings_pressed() -> void:
	if _busy:
		return
	_set_menu_focusable(false) # пока открыты настройки, кнопки позади не должны ловить фокус
	_settings_menu.open()


func _on_settings_closed() -> void:
	_set_menu_focusable(true)
	_settings_button.grab_focus()


func _set_menu_focusable(on: bool) -> void:
	for button: Button in [_play_button, _settings_button, _quit_button]:
		button.focus_mode = Control.FOCUS_ALL if on else Control.FOCUS_NONE


func _on_quit_pressed() -> void:
	if _busy:
		return
	_fade_out(func(): get_tree().quit())


func _fade_out(then: Callable) -> void:
	_busy = true
	_fader.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_fader, "color:a", 1.0, fade_time)
	tween.finished.connect(then)
