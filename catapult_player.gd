extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var turn_speed = 0.2
	var rot_input = -Input.get_axis("ui_left", "ui_right")
	rotate_y(rot_input * turn_speed * delta)
