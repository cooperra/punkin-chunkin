extends Node3D

@export var projectile_scene: PackedScene = preload("res://pumpkin.tscn")
@export var impulse_magnitude = 25.0
@export var input_enabled: bool = true:
	get(): return is_processing_unhandled_input()
	set(value): set_process_unhandled_input(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var turn_speed = 0.4
	var rot_input = -Input.get_axis("ui_left", "ui_right")
	rotate_y(rot_input * turn_speed * delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_launch()
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_launch():
	var projectile: RigidBody3D = projectile_scene.instantiate()
	projectile.position = $LaunchPoint.position
	var root: Node = get_tree().root
	root.add_child(projectile)
	var impulse: Vector3 = $LaunchPoint.global_basis.z * impulse_magnitude
	projectile.apply_central_impulse(impulse)

	# Camera stuff here
	# get current camera (attach script) (check if it's cool enough also)
	# set target to projectile

	# and I guess we'd need a way to get the camera to return home, but that's the whole point of making a second one.

	# Ignore all that above
	#deploy_chase_camera(projectile)
	deploy_rb_camera(projectile, impulse)

func deploy_chase_camera(target: Node3D) -> void:
	var root = get_tree().root
	var chase_camera = preload("res://chase_camera_3d.tscn").instantiate()
	chase_camera.position = $Camera3D.global_position
	chase_camera.basis = $Camera3D.global_basis
	chase_camera.make_current()
	chase_camera.target = target
	root.add_child(chase_camera)

func deploy_rb_camera(target: Node3D, impulse) -> void:
	var root = get_tree().root
	var rb_camera = preload("res://rigid_body_camera_3d.tscn").instantiate()
	root.add_child(rb_camera)
	rb_camera.transform = target.transform
	rb_camera.target = target
	rb_camera.camera.global_position = $Camera3D.global_position
	rb_camera.camera.global_basis = $Camera3D.global_basis
	rb_camera.camera.make_current()
	rb_camera.delayed_launch(impulse, 0.2, 0.75)
