extends CharacterBody2D

@export_group("Ant eater options")
@export var path: NodePath

@onready var _anim = $AnimatedSprite2D
@onready var _sniff_area: Area2D = $"Sniff area"
@onready var _mouth: Node2D = $"Mouth"

enum { STATE_CHASING, STATE_PATROLLING }

var patrol_points
var patrol_index = 0

var target: Node2D

var state = STATE_PATROLLING

const move_speed = 100.0

var sucked_bodies: Array[Node2D] = []
const suck_speed = 50000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim.play()
	patrol_points = get_node(path).curve.get_baked_points()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(sucked_bodies.size() - 1, -1, -1):
		var body = sucked_bodies[i]
		var dir = (_mouth.global_position - body.global_position).normalized()
		if (_mouth.global_position - body.global_position).length() <= 10:
			body.queue_free()
			sucked_bodies.remove_at(i)
			if target == body:
				target = null
				state = STATE_PATROLLING
			continue
		if body is CharacterBody2D:
			body.velocity = dir * suck_speed * delta
			body.move_and_slide()
		else:
			body.position += dir * suck_speed * delta
		body.scale *= 0.98
	
func patrol(delta: float) -> void:
	var target = patrol_points[patrol_index]
	if position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - position).normalized() * move_speed
	
func chase(delta: float) -> void:
	velocity = (target.position - position).normalized() * move_speed

func _physics_process(delta: float):
	if state == STATE_PATROLLING:
		patrol(delta)
	else:
		chase(delta)
		
	rotation = velocity.angle() + deg_to_rad(90)
	move_and_slide()


func _on_sniff_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("ants"):
		target = body
		state = STATE_CHASING


func _on_sniff_area_body_exited(body: Node2D) -> void:
	for b in _sniff_area.get_overlapping_bodies():
		if b.is_in_group("ants"):
			return
	state = STATE_PATROLLING


func _on_suck_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("ants") and sucked_bodies.find(body) == -1:
		sucked_bodies.append(body)
		body.emit_signal("get_sucked")
