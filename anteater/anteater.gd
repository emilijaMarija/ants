extends CharacterBody2D

@export_group("Ant eater options")
@export var path: NodePath

@onready var _anim = $AnimatedSprite2D

var patrol_points
var patrol_index = 0

const move_speed = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim.play()
	patrol_points = get_node(path).curve.get_baked_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float):
	var target = patrol_points[patrol_index]
	if position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - position).normalized() * move_speed
	rotation = velocity.angle() + deg_to_rad(90)
	move_and_slide()
