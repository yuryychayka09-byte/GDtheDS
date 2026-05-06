extends Node3D

@export var segment_scene: PackedScene
@export var segment_length: float = 50.0
@export var visible_segments: int = 6

var segments: Array = []

func _ready():
	# створюємо початкові сегменти
	for i in range(visible_segments):
		var seg = segment_scene.instantiate()
		seg.transform.origin.z = -i * segment_length
		add_child(seg)
		segments.append(seg)

func _process(delta):
	var player = get_node("AirShipHero")
	var player_z = player.global_transform.origin.z

	# перевіряємо сегменти
	for seg in segments:
		# якщо сегмент позаду гравця — переносимо його вперед
		if seg.global_transform.origin.z > player_z + segment_length:
			seg.global_transform.origin.z -= visible_segments * segment_length
