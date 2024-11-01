extends Node3D

var origin_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var meters = global_position.distance_to(origin_position)
	var feet = 3.280839895 * meters
	var yards = feet / 3
	$Label3D.text = "%.1d yd" % yards


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(get_viewport().get_camera_3d().position)
