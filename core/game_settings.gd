class_name GameSettings
extends RefCounted
## Настройки игрока: громкость шин, полноэкранный режим, VSync.
## Хранятся в user://settings.cfg (на Windows: %APPDATA%/Godot/app_userdata/Memory-Pyre/).
## Использование: GameSettings.load_settings(); GameSettings.apply()

const PATH := "user://settings.cfg"

# Громкость в линейной шкале 0..1 (0 — без звука).
static var master_volume: float = 1.0
static var music_volume: float = 0.8
static var sfx_volume: float = 1.0
static var fullscreen: bool = false
static var vsync: bool = true


static func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return # файла ещё нет — остаются значения по умолчанию
	master_volume = float(cfg.get_value("audio", "master", master_volume))
	music_volume = float(cfg.get_value("audio", "music", music_volume))
	sfx_volume = float(cfg.get_value("audio", "sfx", sfx_volume))
	fullscreen = bool(cfg.get_value("video", "fullscreen", fullscreen))
	vsync = bool(cfg.get_value("video", "vsync", vsync))


static func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_volume)
	cfg.set_value("audio", "music", music_volume)
	cfg.set_value("audio", "sfx", sfx_volume)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("video", "vsync", vsync)
	var err := cfg.save(PATH)
	if err != OK:
		push_warning("Не удалось сохранить настройки: %s" % error_string(err))


static func apply() -> void:
	apply_audio()
	apply_video()


static func apply_audio() -> void:
	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)


static func apply_video() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)


static func _set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return # такой шины нет в default_bus_layout.tres
	AudioServer.set_bus_mute(idx, linear <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(linear, 0.001)))
