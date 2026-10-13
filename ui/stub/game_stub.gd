extends Control
## Временная сцена вместо игры. Esc — назад в главное меню.
## Когда появится настоящая первая сцена, укажите её в main_menu.tscn → game_scene_path.

const MAIN_MENU := "res://ui/main_menu/main_menu.tscn"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(MAIN_MENU)
