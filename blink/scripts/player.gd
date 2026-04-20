extends CharacterBody2D

# --- stats ---
@export var speed: float = 80.0
@export var stamina_max: float = 100.0
@export var stamina_drain: float = 20.0
@export var stamina_regen: float = 15.0

# --- state ---
var stamina: float = 100.0
var is_moving: bool = false
var is_exhausted: bool = false
var last_pos: String = ''

# --- node references ---
@onready var sprite = $AnimatedSprite2D

# --- signals ---
signal player_detected

func _ready():
	stamina = stamina_max

func _physics_process(delta: float):
	_handle_movement(delta)
	_handle_stamina(delta)
	_handle_visibility()
	$Label.text = "Stamina: " + str(snappedf(stamina, 0.1))
	move_and_slide()

func _handle_movement(delta: float):
	if is_exhausted:
		velocity = Vector2.ZERO
		is_moving = false
		return
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		sprite.play('walk_right')
		last_pos = 'R'
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
		sprite.play('walk_left')
		last_pos = 'L'
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
		sprite.play('walk_down')
		last_pos = 'D'
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		sprite.play('walk_up')
		last_pos = 'U'
	if direction.length() > 0:
		direction = direction.normalized()
		is_moving = true
	else:
		is_moving = false
		_handle_idle(last_pos)
	velocity = direction * speed

func _handle_stamina(delta: float):
	if is_moving:
		stamina -= stamina_drain * delta
		stamina = clamp(stamina, 0.0, stamina_max)
		if stamina <= 0.0:
			is_exhausted = true
	else:
		if is_exhausted:
			stamina += stamina_regen * delta
			stamina = clamp(stamina, 0.0, stamina_max)
			if stamina >= stamina_max * 0.2:
				is_exhausted = false
		else:
			stamina += stamina_regen * delta
			stamina = clamp(stamina, 0.0, stamina_max)

func _handle_visibility():
	if is_moving and not is_exhausted:
		modulate.a = 0.15
	elif is_exhausted:
		modulate.a = 1.0
	else:
		modulate.a = 1.0

func get_stamina_percent() -> float:
	return stamina / stamina_max

func _handle_idle(idle_pos: String):
	if idle_pos == 'R':
		sprite.play('idle_right')
	elif idle_pos == 'L':
		sprite.play('idle_left')
	elif idle_pos == 'D':
		sprite.play('idle_front')
	elif idle_pos == 'U':
		sprite.play('idle_back');
