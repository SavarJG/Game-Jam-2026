extends CharacterBody2D

@export var speed: float = 40.0
@export var wait_time: float = 1.5
@export var rotation_speed: float = 2.0
@export var reaction_time: float = 0.8

var patrol_points: Array = []
var current_point: int = 0
var waiting: bool = false
var wait_timer: float = 0.0
var reaction_timer: float = 0.0
var player_spotted: bool = false

@onready var vision_cone = $VisionCone
@onready var debug_label = $Label
@onready var noise_radius = $NoiseRadius

func _ready():
	patrol_points.append($PatrolPoints/PointA.global_position)
	patrol_points.append($PatrolPoints/PointB.global_position)

func _physics_process(delta: float):
	_handle_patrol(delta)
	_handle_detection(delta)
	_handle_awareness(delta)
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
	var distance = global_position.distance_to(target)
	if distance < 4.0:
		velocity = Vector2.ZERO
		waiting = true
		wait_timer = wait_time
	else:
		velocity = direction * speed


func _handle_awareness(delta: float):
	var bodies = noise_radius.get_overlapping_bodies()
	var player_visible_nearby = false
	for body in bodies:
		if body.name == "Player":
			if body.modulate.a > 0.5:
				player_visible_nearby = true
				var direction = (body.global_position - global_position).normalized()
				var target_angle = atan2(direction.y, direction.x)
				rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	if not player_visible_nearby:
		player_spotted = false
		reaction_timer = 0.0

func _handle_detection(delta: float):
	var bodies = vision_cone.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			if body.modulate.a > 0.5:
				player_spotted = true
	if player_spotted:
		reaction_timer += delta
		if reaction_timer >= reaction_time:
			get_tree().reload_current_scene()
	else:
		reaction_timer = 0.0
