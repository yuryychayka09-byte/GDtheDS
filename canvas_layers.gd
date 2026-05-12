extends CanvasLayer

func _on_retry_pressed():
	# Перезапуск гри: перезавантажує поточну сцену
	get_tree().reload_current_scene()

func _on_exit_pressed():
	# Вихід з гри
	get_tree().quit()
