extends Node3D

# Підтягуємо сцену сегмента наперед, щоб не було затримки при створенні
var segment_scene: PackedScene = preload("res://Scenes/TunnelSegment.tscn")


@export var segment_length: float = 300.0   # довжина одного сегмента
@export var total_segments: int = 70        # кількість сегментів

var segments: Array = []

func _ready():
	# створюємо всі сегменти підряд
	for i in range(total_segments):
		var seg: Node3D = segment_scene.instantiate()   # ✅ правильний метод
		seg.transform.origin.z = -i * segment_length
		add_child(seg)
		segments.append(seg)
