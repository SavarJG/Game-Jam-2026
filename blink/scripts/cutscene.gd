extends Node2D

var cutscene_played: bool = false
var dialogue_step: int = 0

@onready var player = $Player
@onready var wizard_trigger = $Wizard/WizardArea
@onready var dialogue = $DialogueBox
@onready var corridor_spawn = $Corridor_Spawn
@onready var wizard = $Wizard/AnimatedSprite2D
@onready var fade = $FadeLayer/Fade

func _ready():
	wizard_trigger.body_entered.connect(_on_wizard_area_entered)
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	dialogue.choice_made.connect(_on_choice_made)


	if GameState.respawn_position != Vector2.ZERO:
		player.global_position = GameState.respawn_position
		cutscene_played = true
		$LevelMusic.play()

func _on_wizard_area_entered(body):
	if body.name == "Player" and not cutscene_played:
		cutscene_played = true
		start_cutscene()

func start_cutscene():
	player.set_physics_process(false)
	dialogue_step = 0
	advance()

func advance():
	dialogue_step += 1
	match dialogue_step:
		1:
			dialogue.show_line("Wizard", "Psst. Hey Kid. What ya in for?")
		

		2:
			end_cutscene()

func _on_dialogue_finished():
	advance()

func _on_choice_made(_index: int):
	# All choices lead to same response
	# Store index here later if you want flavour variation
	advance()

func fade_to_black():
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.8)
	await tween.finished


func end_cutscene():
	dialogue.hide_dialogue()
	wizard.play('Teleport')
	wizard.play('Die')
	await get_tree().create_timer(1.5).timeout
	await fade_to_black()
	fade.visible = false
	GameState.respawn_position = corridor_spawn.global_position
	player.global_position = corridor_spawn.global_position
	player.set_physics_process(true)
	$LevelMusic.play()


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		GameState.respawn_position = Vector2.ZERO
		get_tree().change_scene_to_file("res://scenes/level_02.tscn")
