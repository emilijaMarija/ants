extends Node2D

@export_group("Game options")
@export var ant_scene: PackedScene
@export var sugar_scene: PackedScene
@export var apple_scene: PackedScene

@onready var _ants_parent = $Ants
@onready var _sugars_parent = $Sugars
@onready var _apples_parent = $Apples
@onready var _cam = $Camera2D
@onready var _scoreboard = $Scoreboard
@onready var _initial_ant = $Ants/Ant
@onready var _menu = $Menu
@onready var _start_text = $StartText
@onready var _win_menu = $WinMenu
@onready var _loss_menu = $LossMenu

@onready var _sound_ant_multiply = $SoundAntMultiply
@onready var _sound_background: AudioStreamPlayer = $SoundBackground
@onready var _sound_win = $SoundWin

@onready var _sugar_spawn_timer = $"Sugar spawn timer"

const max_sugars = 25
const max_apples = 50

var fade_duration = 0.7

func change_state(state: int) -> void:
	variables.state = state
	if variables.state == variables.STATE_SPLASH:
		begin_splash()
	elif variables.state == variables.STATE_MENU:
		begin_menu()
	elif variables.state == variables.STATE_GAMEPLAY:
		begin_game()
	elif variables.state == variables.STATE_PRE_START:
		begin_pre_start()
	elif variables.state == variables.STATE_FIRST_SUGAR:
		begin_first_sugar()
	elif variables.state == variables.STATE_MENU:
		begin_menu()
	elif variables.state == variables.STATE_WIN:
		begin_win()
	elif variables.state == variables.STATE_RESUME:
		begin_resume()
	elif variables.state == variables.STATE_LOSS:
		begin_loss()
	elif  variables.state == variables.STATE_RETRY:
		begin_retry()

func multiply_ants(count: int) -> void:
	_sound_ant_multiply.play()
	var ant_count = _ants_parent.get_child_count()
	correct_zoom()
	for i in range(max(1, count)):
		var new_ant = ant_scene.instantiate()
		#new_ant.position = _ants_parent.get_child(wrapi(i, 0, _ants_parent.get_child_count())).position
		new_ant.position = find_valid_position_near_ants()
		new_ant.add_to_group("ants")
		_ants_parent.call_deferred("add_child", new_ant)

func find_valid_position_near_ants() -> Vector2:
	var safe_distance = 30
	var max_attempts = 10
	
	var random_ant: Node2D = null
	for attempt in range(max_attempts):
		random_ant = _ants_parent.get_child(randi() % _ants_parent.get_child_count())
		
		var candidate_position = random_ant.global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		
		if is_position_valid(candidate_position, safe_distance):
			return candidate_position
	
	return random_ant.global_position

func is_position_valid(position: Vector2, min_distance: float) -> bool:
	for ant in _ants_parent.get_children():
		if global_position.distance_to(ant.global_position) < min_distance:
			return false 
	return true

func _on_pumpkin_picked_up(pumpkin: Node2D, ant: Node2D) -> void:
	multiply_ants(5)

func _on_apple_picked_up(apple: Node2D, ant: Node2D) -> void:
	multiply_ants(3)
	
func _on_sugar_picked_up(sugar: Node2D, apple: Node2D) -> void:
	multiply_ants(1)
	if variables.state == variables.STATE_FIRST_SUGAR:
		change_state(variables.STATE_SPLASH)

func begin_pre_start() -> void:
	_initial_ant.follow_mouse = false
	await get_tree().create_timer(1).timeout
	fade_in(_start_text.get_node("Info"))
	
func begin_first_sugar() -> void:
	_start_text.visible = false
	_initial_ant.follow_mouse = true
	
func begin_splash() -> void:
	_sound_background.play()
	_menu.visible = true
	await get_tree().create_timer(0.5).timeout
	fade_in(_menu.get_node("Splash"), 0.1)
	await get_tree().create_timer(2).timeout
	fade_out(_menu.get_node("Splash"))
	change_state(variables.STATE_MENU)

func begin_menu() -> void:
	fade_in(_menu.get_node("Info"))

func begin_game() -> void:
	fade_out(_menu.get_node("Info"))
	_scoreboard.visible = true
	_menu.visible = false
	correct_zoom()
	_sugar_spawn_timer.connect("timeout", spawn_sugar)
	for i in 25:
		spawn_sugar()
		_spawn_apple()

func wait_until_playback_position(audio_stream_player: AudioStreamPlayer, target_time: float) -> void:
	while audio_stream_player.get_playback_position() < target_time:
		await get_tree().process_frame.emit()

func begin_win() -> void:
	_win_menu.visible = true
	fade_in(_win_menu.get_node("Info"), 0.5)
	
	const track_len = 80.16
	const bars = 32
	const bar_len = track_len / bars
	var mult = _sound_background.get_playback_position() / (bar_len * 6)
	await get_tree().create_timer(ceil(mult) - mult).timeout
	_sound_background.stop()
	_sound_win.play()
	
func begin_resume() -> void:
	fade_out(_win_menu.get_node("Info"))
	_win_menu.visible = false
	variables.state = variables.STATE_GAMEPLAY

func begin_loss() -> void:
	_loss_menu.visible = true
	fade_in(_loss_menu.get_node("Info"))
	variables.score = 0
	variables.score_updated.emit()

func begin_retry() -> void:
	_sound_background.play()
	_sound_win.stop()
	fade_out(_loss_menu.get_node("Info"))
	_loss_menu.visible = false
	var new_ant = ant_scene.instantiate()
	new_ant.position = Vector2(372,800)
	new_ant.add_to_group("ants")
	new_ant.primary = true
	_ants_parent.call_deferred("add_child", new_ant)
	variables.state = variables.STATE_GAMEPLAY
	

func process_game(delta: float) -> void:
	var avg_pos = Vector2(0, 0)
	var ant_count = _ants_parent.get_child_count()
	
	if ant_count == 0:
		return
	
	for i in range(ant_count):
		avg_pos += _ants_parent.get_child(i).global_position
	if ant_count > 0:
		avg_pos /= ant_count
	_cam.global_position = avg_pos * 0.8 + get_global_mouse_position() * 0.2
		
		
func any_input() -> void:
	if variables.state == variables.STATE_PRE_START:
		change_state(variables.STATE_FIRST_SUGAR)
	elif variables.state == variables.STATE_MENU:
		change_state(variables.STATE_GAMEPLAY)
	elif variables.state == variables.STATE_WIN:
		change_state(variables.STATE_RESUME)
	elif variables.state == variables.STATE_LOSS:
		change_state(variables.STATE_RETRY)
	
func _unhandled_key_input(event):
	if event.is_pressed():
		any_input()
	
		
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		any_input()

func _on_ant_scored():
	correct_zoom()

func _ready() -> void:
	_start_text.get_node("Info").modulate.a = 0
	_menu.get_node("Splash").modulate.a = 0
	_menu.get_node("Info").modulate.a = 0
	_win_menu.get_node("Info").modulate.a = 0
	_loss_menu.get_node("Info").modulate.a = 0
	_initial_ant.primary = true
	_sugar_spawn_timer.connect("timeout", spawn_sugar)
	events.ant_eaten.connect(on_ant_eaten)
	events.apple_eaten.connect(_on_apple_picked_up)
	events.sugar_eaten.connect(_on_sugar_picked_up)
	events.pumpkin_eaten.connect(_on_pumpkin_picked_up)
	events.ant_scored.connect(_on_ant_scored)
	variables.score_updated.connect(_on_score_updated)
	change_state(variables.STATE_PRE_START)

func correct_zoom() -> void:
	var ant_count = _ants_parent.get_child_count()
	_cam.zoom = Vector2(1, 1) * max(pow(0.98, ant_count) * 2, 0.6)
	#_cam.zoom = Vector2(1, 1) * 0.4

func generate_sugar_position() -> Vector2:
	var random_x = randf_range(32, 1000)
	var random_y = randf_range(-1080, 1080)
	
	return Vector2(random_x, random_y)
	

func generate_apple_position() -> Vector2:
	var random_y = randf_range(-2100, 1100)
	var random_x
	
	if random_y < -1200:
		random_x = randf_range(0, 3250)
	else:
		random_x = randf_range(1200, 3250)
	
	
	return Vector2(random_x, random_y)

func spawn_sugar() -> void:
	if variables.state != variables.STATE_GAMEPLAY:
		return
	if _sugars_parent.get_child_count() >= max_sugars:
		return
	var instance = sugar_scene.instantiate()
	instance.position = generate_sugar_position()
	instance.add_to_group("sugars")
	_sugars_parent.add_child(instance)
	
func _spawn_apple() -> void:
	if get_tree().get_nodes_in_group("apples").size() >= max_apples:
		return
	var instance = apple_scene.instantiate()
	instance.position = generate_apple_position()
	instance.add_to_group("apples")
	_apples_parent.add_child(instance)

func on_ant_eaten(body: Node2D) -> void:
	var ant_count = _ants_parent.get_child_count()
	
	if ant_count == 1:
		change_state(variables.STATE_LOSS)
	
	correct_zoom()
	# Pick another primary ant if current one was eaten
	if body.primary:
		for ant in _ants_parent.get_children():
			if not ant.primary:
				ant.primary = true
				return
				
func _on_score_updated() -> void:
	if variables.score == 10:
		change_state(variables.STATE_WIN)
	
func fade_in(node, duration: float = fade_duration):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 1, duration)
	tween.play()
	await tween.finished
	tween.kill()

func fade_out(node, duration: float = fade_duration):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0, duration)
	tween.play()
	await tween.finished
	tween.kill()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if variables.state == variables.STATE_GAMEPLAY:
		process_game(delta)


#func _on_sound_background_finished() -> void:
#	_sound_background.play()


func _on_sound_win_finished() -> void:
	if variables.state == variables.STATE_GAMEPLAY:
		_sound_background.play()
