extends Node3D

# Підтягуємо сцену сегмента наперед
var segment_scene: PackedScene = preload("res://Scenes/static_body_3d.tscn")

@export var segment_length: float = 300.0   # довжина одного сегмента
@export var total_segments: int = 30        # кількість сегментів

var segments: Array = []

func _ready():
	# створюємо рівно total_segments сегментів
	for i in range(total_segments):
		var seg: Node3D = segment_scene.instantiate()
		seg.transform.origin.z = -i * segment_length
		add_child(seg)
		segments.append(seg)

	# після цього нові сегменти НЕ додаються
	# тобто тунель закінчується і далі порожній простір
