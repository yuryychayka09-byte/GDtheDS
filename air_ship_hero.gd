extends CharacterBody3D

const MAX_SPEED = 120.0
const ACCELERATION = 10.0
const TURN_SPEED = 1.5
const PITCH_SPEED = 1.2
const ALIGN_SPEED = 4.0   # швидкість вирівнювання на приціл

var current_speed: float = 0.0

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: Node3D = $Crosshair
@onready var speed_label: Label = $"../CanvasLayer/SpeedLabel"   # ✅ HUD швидкості

func _physics_process(delta: float) -> void:
	# --- Регулювання швидкості колесом мишки ---
	if Input.is_action_just_pressed("throttle_wheel_up"):
		current_speed = min(current_speed + ACCELERATION, MAX_SPEED)
	elif Input.is_action_just_pressed("throttle_wheel_down"):
		current_speed = max(current_speed - ACCELERATION, 0)

	# --- Допоміжний тангаж (W/S) ---
	if Input.is_action_pressed("throttle_up"): # W
		rotate_object_local(Vector3.RIGHT, -PITCH_SPEED * delta)
	elif Input.is_action_pressed("throttle_down"): # S
		rotate_object_local(Vector3.RIGHT, PITCH_SPEED * delta)

	# --- Допоміжний крен (A/D) ---
	if Input.is_action_pressed("roll_left"):
		rotate_object_local(Vector3.FORWARD, -TURN_SPEED * delta)
	elif Input.is_action_pressed("roll_right"):
		rotate_object_local(Vector3.FORWARD, TURN_SPEED * delta)

	# --- Рух вперед тільки якщо швидкість > 0 ---
	if current_speed > 0.0:
		velocity = -transform.basis.z * current_speed
		move_and_slide()
	else:
		velocity = Vector3.ZERO


func _process(delta: float) -> void:
	# --- Оновлення HUD швидкості ---
	speed_label.text = "Швидкість: " + str(round(current_speed)) + " км/год"

	# --- Мишка працює тільки при русі ---
	if current_speed > 0.1:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		crosshair.global_transform.origin = to

		# --- Вирівнювання на приціл ---
		var target_dir = (crosshair.global_transform.origin - global_transform.origin).normalized()
		var current_dir = -transform.basis.z

		# чутливість залежить від швидкості: на високій швидкості поворот повільніший
		var speed_factor = clamp(1.0 - (current_speed / MAX_SPEED) * 0.6, 0.4, 1.0)
		var new_dir = current_dir.slerp(target_dir, ALIGN_SPEED * speed_factor * delta)

		# крен не чіпаємо — він працює окремо
		look_at(global_transform.origin + new_dir, self.basis.y)
