extends Node3D

@export var projectile_scene: PackedScene = preload("res://pumpkin.tscn")
@export var impulse_magnitude = 30.0
@export var input_enabled: bool = true:
	get(): return is_processing_unhandled_input()
	set(value): set_process_unhandled_input(value)

@onready var vert_aim_value: float = -$LaunchPoint.rotation_degrees.x
@onready var vert_aim_starting_value: float = -$LaunchPoint.rotation_degrees.x
@onready var camera_starting_pitch: float = $Camera3D.rotation_degrees.x

enum PlayerState {
	AIMING,
	LAUNCHING,
}
var state: PlayerState = PlayerState.AIMING:
	set(value):
		state = value
		match state:
			PlayerState.AIMING:
				set_process_unhandled_input(true)
				set_physics_process(true)
				if not is_node_ready():
					return
				# Reset aim to keep the game from being too easy
				var random_aim_window = 20  # degrees
				var random_nudge = randf() * random_aim_window - random_aim_window / 2
				vert_aim_value = vert_aim_starting_value + random_nudge
				update_aim()
			PlayerState.LAUNCHING:
				set_process_unhandled_input(false)
				set_physics_process(false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var turn_speed = 0.4
	var rot_input = -Input.get_axis("aim_left", "aim_right")
	if rot_input != 0:
		rotate_y(rot_input * turn_speed * delta)
	# Skip vertical input if we're turning
	if rot_input != 0:
		return
	# We're doing a wonky thing where vert_aim_value goes from 0 to 80,
	# but the actual rotation goes from 0 to -80 degrees.
	var vert_aim_max = 80
	var vert_aim_min = 0
	var vert_turn_speed = 0.3 * vert_aim_max
	var vert_input = Input.get_axis("aim_down", "aim_up")
	if vert_input == 0:
		return
	vert_aim_value += vert_input * vert_turn_speed * delta
	vert_aim_value = clampf(vert_aim_value, vert_aim_min, vert_aim_max)
	update_aim()

func update_aim():
	$LaunchPoint.rotation_degrees.x = -vert_aim_value
	# Camera is technically facing the opposite direction of our aim.
	$Camera3D.rotation_degrees.x = 0.3 * (vert_aim_value - vert_aim_starting_value) + camera_starting_pitch

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("launch"):
		_on_launch()
	if event.is_action_pressed("quit"):
		get_tree().quit()


func _on_launch():
	state = PlayerState.LAUNCHING
	var projectile: RigidBody3D = projectile_scene.instantiate()
	projectile.position = $LaunchPoint.position
	var root: Node = get_tree().root
	root.add_child(projectile)
	var impulse: Vector3 = $LaunchPoint.global_basis.z * impulse_magnitude
	projectile.apply_central_impulse(impulse)
	# Randomize initial rotation
	projectile.rotation = Vector3(randf() * 2 * PI, randf() * 2 * PI, randf() * 2 * PI)
	# Randomize spin a little
	var spin_magnitude: float = randf() * PI / 2
	var spin_direction: Vector3 = Vector3(randf(), randf(), randf()).normalized()
	projectile.angular_velocity = spin_magnitude * spin_direction
	deploy_rb_camera(projectile, impulse)

func deploy_rb_camera(target: Node3D, impulse) -> void:
	var root = get_tree().root
	var rb_camera = preload("res://rigid_body_camera_3d.tscn").instantiate()
	rb_camera.tree_exited.connect(func (): state = PlayerState.AIMING, CONNECT_ONE_SHOT)
	root.add_child(rb_camera)
	rb_camera.transform = target.transform
	rb_camera.target = target
	rb_camera.camera.global_position = $Camera3D.global_position
	rb_camera.camera.global_basis = $Camera3D.global_basis
	rb_camera.camera.make_current()
	rb_camera.delayed_launch(impulse, 0.2, 0.75)
