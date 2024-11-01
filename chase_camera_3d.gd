extends Camera3D

@export var target: Node3D
@export var distance: float = 10
@export var acceleration: float = 100
@export var deceleration: float = 100
# global
@export var current_velocity: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not target:
		return
	look_at(target.global_position)
	# Our -Z axis is now facing the target
	var direction_to_target = -global_basis.z.normalized()
	global_position += current_velocity * delta
	var current_distance: float = global_position.distance_to(target.global_position)
	if current_distance > distance:
		current_velocity += direction_to_target * acceleration * delta
	elif current_distance < distance:
		current_velocity -= direction_to_target * deceleration * delta
