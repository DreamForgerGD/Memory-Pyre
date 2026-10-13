extends Control
## Окно настроек. Открывается через open(), закрывается кнопкой «Назад» или Esc.
## Изменения применяются сразу, в файл сохраняются при закрытии.

signal closed

@onready var _master_slider: HSlider = %MasterSlider
@onready var _music_slider: HSlider = %MusicSlider
@onready var _sfx_slider: HSlider = %SfxSlider
@onready var _master_value: Label = %MasterValue
@onready var _music_value: Label = %MusicValue
@onready var _sfx_value: Label = %SfxValue
@onready var _fullscreen_check: CheckButton = %FullscreenCheck
@onready var _vsync_check: CheckButton = %VsyncCheck
@onready var _back_button: Button = %BackButton
@onready var _grid: GridContainer = $Panel/VBox/Grid

const LABEL_COLOR := Color(0.72, 0.73, 0.77)
const LABEL_FOCUS_COLOR := Color(1.0, 0.86, 0.62)


func _ready() -> void:
	_setup_focus()
	_master_slider.value_changed.connect(_on_master_changed)
	_music_slider.value_changed.connect(_on_music_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	_vsync_check.toggled.connect(_on_vsync_toggled)
	_back_button.pressed.connect(close)


## Замыкает перемещение фокуса внутри окна (вверх/вниз по кругу),
## чтобы он не уходил на кнопки меню позади, и подсвечивает подпись выбранной строки.
func _setup_focus() -> void:
	var order: Array[Control] = [_master_slider, _music_slider, _sfx_slider,
			_fullscreen_check, _vsync_check, _back_button]
	for i in order.size():
		var c := order[i]
		var prev := order[(i - 1 + order.size()) % order.size()]
		var next := order[(i + 1) % order.size()]
		c.focus_neighbor_top = c.get_path_to(prev)
		c.focus_neighbor_bottom = c.get_path_to(next)
		c.focus_previous = c.get_path_to(prev)
		c.focus_next = c.get_path_to(next)
		# Ползунки сами обрабатывают влево/вправо; остальным не даём уйти вбок.
		if not c is HSlider:
			c.focus_neighbor_left = c.get_path_to(c)
			c.focus_neighbor_right = c.get_path_to(c)
		var label := _row_label(c)
		if label:
			c.focus_entered.connect(func(): label.add_theme_color_override("font_color", LABEL_FOCUS_COLOR))
			c.focus_exited.connect(func(): label.add_theme_color_override("font_color", LABEL_COLOR))
		c.mouse_entered.connect(c.grab_focus)


## Подпись слева от элемента в той же строке сетки (или null).
func _row_label(c: Control) -> Label:
	if c.get_parent() != _grid:
		return null
	var idx := c.get_index()
	var label_idx := idx - idx % _grid.columns
	return _grid.get_child(label_idx) as Label


func open() -> void:
	# set_value_no_signal — чтобы заполнение полей не вызывало повторное применение.
	_master_slider.set_value_no_signal(GameSettings.master_volume)
	_music_slider.set_value_no_signal(GameSettings.music_volume)
	_sfx_slider.set_value_no_signal(GameSettings.sfx_volume)
	_fullscreen_check.set_pressed_no_signal(GameSettings.fullscreen)
	_vsync_check.set_pressed_no_signal(GameSettings.vsync)
	_refresh_labels()
	show()
	_master_slider.grab_focus()


func close() -> void:
	if not visible:
		return
	GameSettings.save_settings()
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _on_master_changed(value: float) -> void:
	GameSettings.master_volume = value
	GameSettings.apply_audio()
	_refresh_labels()


func _on_music_changed(value: float) -> void:
	GameSettings.music_volume = value
	GameSettings.apply_audio()
	_refresh_labels()


func _on_sfx_changed(value: float) -> void:
	GameSettings.sfx_volume = value
	GameSettings.apply_audio()
	_refresh_labels()


func _on_fullscreen_toggled(on: bool) -> void:
	GameSettings.fullscreen = on
	GameSettings.apply_video()


func _on_vsync_toggled(on: bool) -> void:
	GameSettings.vsync = on
	GameSettings.apply_video()


func _refresh_labels() -> void:
	_master_value.text = "%d%%" % roundi(_master_slider.value * 100.0)
	_music_value.text = "%d%%" % roundi(_music_slider.value * 100.0)
	_sfx_value.text = "%d%%" % roundi(_sfx_slider.value * 100.0)
