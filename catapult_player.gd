extends Node3D

@export var projectile_scene: PackedScene = preload("res://pumpkin.tscn")
@export var impulse = 25.0

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
	var root = get_tree().root
	root.add_child(projectile)
	projectile.apply_central_impulse($LaunchPoint.global_basis.z * impulse)
