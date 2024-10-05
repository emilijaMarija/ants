extends CharacterBody2D

const movement_speed: float = 50.0
const rotation_speed: float = 10.0

@onready var _animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()

	look_at(mouse_position)
	move_towards_mouse(mouse_position)
	
	
func move_towards_mouse(mouse_position: Vector2) -> void:
	var direction = (mouse_position - global_position).normalized()
	velocity = direction * movement_speed
	print(velocity)
	move_and_slide()
	
