extends CharacterBody3D

const MAX_SPEED = 120.0
const ACCELERATION = 10.0
const TURN_SPEED = 1.5
const PITCH_SPEED = 1.2
const ALIGN_SPEED = 4.0
const MAX_COLLISIONS = 1000   # поріг програшу

var current_speed: float = 0.0
var collision_count: int = 0

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: Node3D = $Crosshair
@onready var speed_label: Label = get_node("/root/Node3D/HUD/SpeedLabel")
@onready var collision_label: Label = get_node("/root/Node3D/HUD/CollisionLabel")
@onready var game_over_screen: CanvasLayer = get_node("/root/Node3D/GameOver")

func _ready() -> void:
	collision_count = 0
	game_over_screen.visible = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("throttle_wheel_up"):
		current_speed = min(current_speed + ACCELERATION, MAX_SPEED)
	elif Input.is_action_just_pressed("throttle_wheel_down"):
		current_speed = max(current_speed - ACCELERATION, 0)

	if Input.is_action_pressed("throttle_up"):
		rotate_object_local(Vector3.RIGHT, -PITCH_SPEED * delta)
	elif Input.is_action_pressed("throttle_down"):
		rotate_object_local(Vector3.RIGHT, PITCH_SPEED * delta)

	if Input.is_action_pressed("roll_left"):
		rotate_object_local(Vector3.FORWARD, -TURN_SPEED * delta)
	elif Input.is_action_pressed("roll_right"):
		rotate_object_local(Vector3.FORWARD, TURN_SPEED * delta)

	if current_speed > 0.0:
		velocity = -transform.basis.z * current_speed
		move_and_slide()

		# --- Перевірка зіткнень ---
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision and collision.get_collider():
				collision_count += 1
				break
	else:
		velocity = Vector3.ZERO

	# --- Перевірка програшу ---
	if collision_count >= MAX_COLLISIONS and not game_over_screen.visible:
		_trigger_game_over()

func _process(delta: float) -> void:
	if speed_label:
		speed_label.text = "Швидкість: " + str(round(current_speed)) + " км/год"

	if collision_label:
		collision_label.text = "Зіткнення: " + str(collision_count)

	if current_speed > 0.1:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		crosshair.global_transform.origin = to

		var target_dir = (crosshair.global_transform.origin - global_transform.origin).normalized()
		var current_dir = -transform.basis.z

		var speed_factor = clamp(1.0 - (current_speed / MAX_SPEED) * 0.6, 0.4, 1.0)
		var new_dir = current_dir.slerp(target_dir, ALIGN_SPEED * speed_factor * delta)

		look_at(global_transform.origin + new_dir, self.basis.y)

# --- Функція програшу ---
func _trigger_game_over() -> void:
	current_speed = 0
	game_over_screen.visible = true

# --- Обробка кнопок Game Over ---
func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().quit()
