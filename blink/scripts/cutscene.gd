extends Node2D

var cutscene_played: bool = false
var dialogue_step: int = 0

@onready var player = $Player
@onready var wizard_trigger = $Wizard/WizardArea
@onready var dialogue = $DialogueBox
@onready var corridor_spawn = $CorridorSpawn

func _ready():
	wizard_trigger.body_entered.connect(_on_wizard_area_entered)
	dialogue.dialogue_finished.connect(_on_dialogue_finished)
	dialogue.choice_made.connect(_on_choice_made)

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
			dialogue.show_line("You", "...", [
				"Killed a midget",
				"Killed a goblin",
				"Killed a squid"
			])

		3:
			dialogue.show_line("Wizard", "Damn. You really had no choice but to kill. Anyway, have ya ever heard of Super Mario?.")

		4:
			dialogue.show_line("You", "...", [
				"Nah, whats a mario?",
				"Yeah, he's my plumber.",
				"..."
			])
		5:
			dialogue.show_line("Wizard", "Yeah so basically Marios Bitch is always getting stolen and he has to go save her everytime")
			
		6:
			dialogue.show_line("You", "Ok... im not following though")

		7:
			dialogue.show_line("Wizard", "I'm like mario man, I have to escape this dungeon. Get to the top and save this hoe ass princess")

		8:
			dialogue.show_line("You", "...", [
				"Goodluck with that man, i'm just going to die in here. Outside was boring anyway",
				"Let me not stop ya",
				"..."
			])

		9:
			dialogue.show_line("Wizard", "No listen, I CANT save her. You HAVE TO now. Im not going to be around much longer")

		10:
			dialogue.show_line("You", "WHAT! Why cant you save her man?")

		11:
			dialogue.show_line("Wizard", "Listen man, even 100 year old wizards make mistakes")

		12:
			dialogue.show_line("You", "What kind of mistakes?")

		13:
			dialogue.show_line("Wizard", "Sigh, I was trying to get with this Zulu chick. Tried to cast a spell to pay her labola and........... accidentally gave myself Ebola.")

		14:
			dialogue.show_line("You", "Fuck thats deep")

		15:
			dialogue.show_line("Wizard", "I know. But listen you're going to save her. I know you can. Before I die in this cell , i'm going to give you the power too")

		16:
			dialogue.show_line("You", "How?")

		17:
			dialogue.show_line("Wizard", "I'm going to cast a spell on you . When you move you'll be invisible. Stand still, seen. Got it? I hope. Use these powers to escape through the catacombs and find the princess...")

		18:
			dialogue.show_line("You", "I got it!")

		19:
			end_cutscene()

func _on_dialogue_finished():
	advance()

func _on_choice_made(_index: int):
	# All choices lead to same response
	# Store index here later if you want flavour variation
	advance()

func end_cutscene():
	dialogue.hide_dialogue()
	player.global_position = corridor_spawn.global_position
	player.set_physics_process(true)
