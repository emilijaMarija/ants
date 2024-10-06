extends Node2D

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var _area: Area2D = $Area2D
@onready var _sound_score: AudioStreamPlayer = $ScoreSound

const suck_speed = 50000.0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("ants").size() <= 1:
		return
	for body in _area.get_overlapping_bodies():
		if not body.is_in_group("ants"):
			continue
		if body.primary:
			continue
		body.follow_mouse = false
		(body as CharacterBody2D).velocity = (global_position - body.global_position).normalized() * suck_speed * delta
		(body as CharacterBody2D).move_and_slide()
		events.ant_scored.emit()
		if body.global_position.distance_to(global_position) <= 10:
			body.queue_free()
			variables.score += 10
			variables.score_updated.emit()
			_sound_score.play()
