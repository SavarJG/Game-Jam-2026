extends CanvasLayer

signal dialogue_finished
signal choice_made(index)

var full_text: String = ""
var displayed_text: String = ""
var char_timer: float = 0.0
var char_delay: float = 0.03
var is_typing: bool = false
var waiting_for_choice: bool = false

@onready var speaker_label = $Panel/SpeakerName
@onready var text_label = $Panel/DialogueText
@onready var choices = $Panel/Choices
@onready var advance_hint = $Panel/AdvanceHint

func _ready():
	visible = false
	choices.visible = false
	advance_hint.visible = false
	$Panel/Choices/Choice1.pressed.connect(func(): _on_choice(0))
	$Panel/Choices/Choice2.pressed.connect(func(): _on_choice(1))
	$Panel/Choices/Choice3.pressed.connect(func(): _on_choice(2))

func show_line(speaker: String, text: String, choices_list: Array = []):
	visible = true
	speaker_label.text = speaker
	full_text = text
	displayed_text = ""
	is_typing = true
	char_timer = 0.0
	advance_hint.visible = false
	choices.visible = false
	waiting_for_choice = choices_list.size() > 0
	if waiting_for_choice:
		$Panel/Choices/Choice1.text = choices_list[0]
		$Panel/Choices/Choice2.text = choices_list[1]
		$Panel/Choices/Choice3.text = choices_list[2]

func hide_dialogue():
	visible = false

func _process(delta):
	if not is_typing:
		return
	char_timer += delta
	if char_timer >= char_delay:
		char_timer = 0.0
		if displayed_text.length() < full_text.length():
			displayed_text += full_text[displayed_text.length()]
			text_label.text = displayed_text
		else:
			is_typing = false
			if waiting_for_choice:
				choices.visible = true
			else:
				advance_hint.visible = true
				advance_hint.text = "[ E to continue ]"

func _unhandled_input(event):
	if not visible:
		return
	if is_typing:
		displayed_text = full_text
		text_label.text = full_text
		is_typing = false
		if waiting_for_choice:
			choices.visible = true
		else:
			advance_hint.visible = true
		return
	if event.is_action_pressed("ui_accept") and not waiting_for_choice:
		dialogue_finished.emit()

func _on_choice(index: int):
	choices.visible = false
	waiting_for_choice = false
	choice_made.emit(index)
