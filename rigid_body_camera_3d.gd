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

var woosh_audio_tween: Tween
var woosh_is_playing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_input(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	track_target()
	update_woosh_audio()

func track_target():
	if not target:
		return
	camera.look_at(target.global_position)

func update_woosh_audio():
	var should_play = linear_velocity.length_squared() > 0
	var woosh_is_playing = %WindSoundPlayer.playing
	if not woosh_is_playing and should_play:
		woosh_is_playing = true
		# Ramp up volume
		if woosh_audio_tween:
			woosh_audio_tween.kill()
		woosh_audio_tween = %WindSoundPlayer.create_tween()
		woosh_audio_tween.tween_property(%WindSoundPlayer, "volume_db", 0, 0.2).from(-80)
		# Random start
		var stream: AudioStream = %WindSoundPlayer.stream
		var start_point = randf() * stream.get_length()
		# Play
		%WindSoundPlayer.play(start_point)
	if woosh_is_playing and not should_play:
		woosh_is_playing = false
		# Ramp down volume
		if woosh_audio_tween:
			woosh_audio_tween.kill()
		woosh_audio_tween = %WindSoundPlayer.create_tween()
		woosh_audio_tween.tween_property(%WindSoundPlayer, "volume_db", -80, 1).from_current()
		# Stop after done
		woosh_audio_tween.finished.connect(%WindSoundPlayer.stop)

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
