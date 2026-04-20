extends CharacterBody2D

@export var speed: float = 40.0
@export var wait_time: float = 1.5
@export var rotation_speed: float = 2.0
@export var reaction_time: float = 0.8

var patrol_points: Array = []
var current_point: int = 0
var waiting: bool = false
var wait_timer: float = 0.0
var is_alerted: bool = false
var is_killing: bool = false

@onready var vision_cone = $VisionCone
@onready var noise_radius = $NoiseRadius
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	patrol_points.append($PatrolPoints/PointA.global_position)
	patrol_points.append($PatrolPoints/PointB.global_position)
	$VisionCone.body_entered.connect(_on_body_entered_vision)

func _physics_process(delta: float):
	_handle_noise(delta)
	_handle_vision_detection()
	if not is_alerted:
		_handle_patrol(delta)
	move_and_slide()

func _handle_patrol(delta: float):
	if waiting:
		wait_timer -= delta
		if wait_timer <= 0.0:
			waiting = false
			current_point = (current_point + 1) % patrol_points.size()
		return
	var target = patrol_points[current_point]
	var direction = (target - global_position).normalized()
	_handle_animation(direction)
	_update_vision_cone(direction)
	var distance = global_position.distance_to(target)
	if distance < 4.0:
		velocity = Vector2.ZERO
		waiting = true
		wait_timer = wait_time
	else:
		velocity = direction * speed

func _handle_noise(delta: float):
	var bodies = noise_radius.get_overlapping_bodies()
	var player_visible = false
	var player_direction = Vector2.ZERO
	for body in bodies:
		if body.name == "Player" and body.modulate.a > 0.5:
			player_visible = true
			player_direction = (body.global_position - global_position).normalized()
			break
	if player_visible:
		is_alerted = true
		velocity = Vector2.ZERO
		_handle_animation(player_direction)
		_update_vision_cone(player_direction)
	else:
		is_alerted = false

func _on_body_entered_vision(body):
	if body.name == "Player" and body.modulate.a > 0.5:
		_kill_player(body)

func _handle_vision_detection():
	if is_killing:
		return
	var bodies = vision_cone.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player" and body.modulate.a > 0.5:
			_kill_player(body)
			return

func _kill_player(player):
	if is_killing:
		return
	is_killing = true
	$Kill.play()
	player.kill()

func _update_vision_cone(direction: Vector2):
	var angle = atan2(direction.y, direction.x)
	var snapped = round(angle / (PI / 4)) * (PI / 4)
	vision_cone.rotation = snapped

func _handle_animation(directioning: Vector2):
	if abs(directioning.x) > abs(directioning.y):
		if directioning.x > 0:
			animated_sprite.play('walk_right')
		else:
			animated_sprite.play('walk_left')
	else:
		if directioning.y > 0:
			animated_sprite.play('walk_down')
		else:
			animated_sprite.play('walk_up')
