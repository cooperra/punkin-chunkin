extends RigidBody3D

signal on_impact()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for contact_idx in range(state.get_contact_count()):
		# We'll just call any collision good enough for now.
		_on_impact();
		# TODO something elaborate
		var impulse: Vector3 = state.get_contact_impulse(contact_idx)
		if impulse.length() > 1:
			print("IMPULSE %s" % impulse.length())
			print("  VELOCITY %s" % state.linear_velocity.length())
			print("  CONTACT V %s" % state.get_contact_local_velocity_at_position(contact_idx))
			#_on_impact()

func _on_impact():
	on_impact.emit()
	get_tree().create_timer(30).timeout.connect(queue_free)
