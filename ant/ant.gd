extends RigidBody2D

const movement_speed: float = 15.0
const rotation_speed: float = 10.0

@onready var _animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var mouse = get_global_mouse_position()
	#set_global_position(mouse)
	pass
	
	
func _integrate_forces(state):
	var mouse = get_global_mouse_position()
	var target_rotation_vec = mouse - get_global_position();
	var rotation_vec = Vector2(cos(rotation - deg_to_rad(90)), sin(rotation - deg_to_rad(90)))
	
	var speed_mult = 1.0
	var dist = mouse.distance_to(get_global_position())
	if dist < 500:
		speed_mult = max(dist / 500.0, 0.5)
	if dist > 50:
		state.apply_force(rotation_vec.normalized() * movement_speed * speed_mult)
	
	var angle_diff = lerp_angle(rotation - deg_to_rad(90), target_rotation_vec.angle(), 0.6)
	state.angular_velocity = (angle_diff - rotation + deg_to_rad(90)) * rotation_speed
	
