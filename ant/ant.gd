extends RigidBody2D

const movement_speed: float = 5.0
const rotation_speed: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_constant_central_force(Vector2(5.0, 0.0))

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _integrate_forces(state):
	var mouse = get_global_mouse_position()
	var rotation_vec = Vector2(cos(rotation - deg_to_rad(90)), sin(rotation - deg_to_rad(90)))
	var target_rotation_vec = mouse - position;
	
	if rotation_vec.angle_to(target_rotation_vec) < 0:
		state.angular_velocity = -rotation_speed
	else:
		state.angular_velocity = rotation_speed
	state.apply_force(rotation_vec.normalized() * movement_speed)
	
