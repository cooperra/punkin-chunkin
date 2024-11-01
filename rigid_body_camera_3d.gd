extends RigidBody3D

@export var target: Node3D:
	set(value):
		target = value
		if target != null and target.has_signal("on_impact") and not target.on_impact.is_connected(on_target_impact):
			target.on_impact.connect(on_target_impact, CONNECT_ONE_SHOT)
#@export var distance: float = 10
#@export var acceleration: float = 100
#@export var deceleration: float = 100
# global
#@export var current_velocity: Vector3 = Vector3.ZERO
@onready var camera = %Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_input(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not target:
		return
	camera.look_at(target.global_position)
	# Our -Z axis is now facing the target
	#var direction_to_target = -global_basis.z.normalized()
	#global_position += current_velocity * delta
	#var current_distance: float = global_position.distance_to(target.global_position)
	#if current_distance > distance:
		#current_velocity += direction_to_target * acceleration * delta
	#elif current_distance < distance:
		#current_velocity -= direction_to_target * deceleration * delta

func delayed_launch(impulse: Vector3, launch_delay: float, camera_tween_duration: float):
	apply_delayed_impulse(impulse, launch_delay)
	close_camera_distance(camera_tween_duration)

func apply_delayed_impulse(impulse: Vector3, delay: float):
	freeze = true
	await get_tree().create_timer(delay).timeout
	freeze = false
	apply_impulse(impulse)

func close_camera_distance(duration: float):
	camera.create_tween().tween_property(camera, "position", Vector3.ZERO, duration)

func on_target_impact():
	freeze = true
	await get_tree().create_timer(2).timeout
	#skippable_phase_started.emit()
	set_process_unhandled_input(true)
	await get_tree().create_timer(5).timeout
	finish()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		finish()

func finish():
	queue_free()
