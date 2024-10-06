extends CharacterBody2D

const movement_speed: float = 150.0
const rotation_speed: float = 10.0

signal get_sucked

enum { STATE_FOLLOWING, STATE_SUCKED }

var state = STATE_FOLLOWING

@onready var _animated_sprite = $AnimatedSprite2D

func _handle_suck() -> void:
	state = STATE_SUCKED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play("default")
	get_sucked.connect(_handle_suck)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()

	if state == STATE_FOLLOWING:
		look_at(mouse_position)
		move_towards_mouse(mouse_position)
	
	
func move_towards_mouse(mouse_position: Vector2) -> void:
	var direction = (mouse_position - global_position).normalized()
	velocity = direction * movement_speed
	move_and_slide()
	
