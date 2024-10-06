extends CharacterBody2D

@export_group("Ant eater options")
@export var path: NodePath

@onready var _sound_lick: AudioStreamPlayer = $LickSound
@onready var _sound_sniff: AudioStreamPlayer = $SniffSound
@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _sniff_area: Area2D = $"Sniff area"
@onready var _mouth: Node2D = $"Mouth"
@onready var _suck_timer: Timer = $"Suck timer"
@onready var _suck_cooldown: Timer = $"Suck cooldown"

enum { STATE_CHASING, STATE_PATROLLING, STATE_SUCKING }

var patrol_points = []
var patrol_index = 0

var target: Node2D

var state = STATE_PATROLLING

const move_speed = 100.0

var sucked_bodies: Array[Node2D] = []
const suck_speed = 50000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_anim.play("walk")
	var pathNode = get_node(path)
	for pnt in pathNode.curve.get_baked_points():
		patrol_points.append(pnt + pathNode.global_position)


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
			events.ant_eaten.emit(body)
			_sound_lick.play()
			continue
		if body is CharacterBody2D:
			body.velocity = dir * suck_speed * delta
			body.move_and_slide()
		else:
			body.position += dir * suck_speed * delta
		body.scale *= 0.98
	
func patrol(delta: float) -> void:
	var target = patrol_points[patrol_index]
	if global_position.distance_to(target) < 1:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
	velocity = (target - global_position).normalized() * move_speed
	rotation = velocity.angle() + deg_to_rad(90)
	
func chase(delta: float) -> void:
	if not is_instance_valid(target):
		target = null
		state = STATE_PATROLLING
		return
	velocity = (target.position - position).normalized() * move_speed
	rotation = velocity.angle() + deg_to_rad(90)

func _physics_process(delta: float):
	if state == STATE_PATROLLING:
		patrol(delta)
	elif state == STATE_CHASING:
		chase(delta)
	else:
		velocity = Vector2(0, 0)
		pass
		
	move_and_slide()


func _on_sniff_area_body_entered(body: Node2D) -> void:
	if state == STATE_PATROLLING and body.is_in_group("ants"):
		target = body
		state = STATE_CHASING
		_anim.play("walk")
		_sound_sniff.play()


func _on_sniff_area_body_exited(body: Node2D) -> void:
	if state != STATE_CHASING:
		return
	for b in _sniff_area.get_overlapping_bodies():
		if b.is_in_group("ants"):
			return
	state = STATE_PATROLLING


func _on_suck_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("ants") and sucked_bodies.find(body) == -1:
		if state != STATE_SUCKING and _suck_cooldown.time_left <= 0:
			state = STATE_SUCKING
			_anim.play("suck")
			_suck_timer.start()
		elif state != STATE_SUCKING:
			return
		sucked_bodies.append(body)
		body.follow_mouse = false


func _on_suck_timer_timeout() -> void:
	_suck_cooldown.start()
	_anim.play("walk")
	state = STATE_PATROLLING
	for body in sucked_bodies:
		if not body.is_queued_for_deletion():
			body.follow_mouse = true
	sucked_bodies.clear()
