extends CharacterBody2D

const movement_speed: float = 150.0
const rotation_speed: float = 10.0

var follow_mouse = true
var primary = false

@onready var _animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()

	if follow_mouse:
		look_at(mouse_position)
		move_towards_mouse(mouse_position)
	
	
func move_towards_mouse(mouse_position: Vector2) -> void:
	var direction = (mouse_position - global_position).normalized()
	var dist_to_mouse = (global_position - get_global_mouse_position()).length()
	var mouse_mult = min(dist_to_mouse, 80.0) / 80.0
	velocity = direction * movement_speed * mouse_mult
	move_and_slide()
	
