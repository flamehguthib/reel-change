
extends ColorRect

@onready var dialogue_text: RichTextLabel = $DialogueText
@onready var continue_prompt: Label = $ContinuePrompt
@onready var fade_overlay: ColorRect = get_parent().get_node("FadeOverlay") as ColorRect
var ending := false

var dialogue_lines = [
	{
		"speaker": "fisherman",
		"text": "Anak! I'm finally home."
	},
	{
		"speaker": "daughter",
		"text": "Papa! You're back!"
	},
	{
		"speaker": "fisherman",
		"text": "Of course. I wouldn't forget your special day!"
	},
	{
		"speaker": "daughter",
		"text": "Did you bring something for me?"
	},
	{
		"speaker": "fisherman",
		"text": "I did. This is for you, anak."
	},
	{
		"speaker": "daughter",
		"text": "Thank you, Papa! I love it!"
	}
]

var current_line := 0
var typing := false

@export var typing_speed := 20.0

var character_timer := 0.0


func _ready() -> void:
	# Start with a completely black screen
	fade_overlay.modulate.a = 1.0

	# Fade from black to the victory cutscene
	var tween = create_tween()
	tween.tween_property(
		fade_overlay,
		"modulate:a",
		0.0,
		2.0
	)
	
	await tween.finished
	
	continue_prompt.hide()
	show_dialogue()


func _process(delta: float) -> void:
	if typing:
		character_timer += delta

		var characters_to_show := int(character_timer * typing_speed)
		dialogue_text.visible_characters = characters_to_show

		if dialogue_text.visible_characters >= dialogue_text.get_total_character_count():
			typing = false
			continue_prompt.show()


func _input(event: InputEvent) -> void:
	if ending:
		return
		
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		if typing:
			# Immediately reveal the entire current line
			dialogue_text.visible_characters = -1
			typing = false
			continue_prompt.show()
		else:
			# Move to the next dialogue line
			current_line += 1

			if current_line < dialogue_lines.size():
				show_dialogue()
			else:
				finish_dialogue()


func show_dialogue() -> void:
	var line = dialogue_lines[current_line]

	dialogue_text.text = line["text"]
	dialogue_text.visible_characters = 0

	# Position dialogue according to the speaker
	if line["speaker"] == "fisherman":
		dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	elif line["speaker"] == "daughter":
		dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	character_timer = 0.0
	typing = true

	continue_prompt.show()
	continue_prompt.hide()


func finish_dialogue() -> void:
	if ending:
		return

	ending = true
	continue_prompt.hide()

	# Fade the entire screen to black
	var tween = create_tween()
	tween.tween_property(
		fade_overlay,
		"modulate:a",
		1.0,
		2.0
	)

	await tween.finished

	var error = get_tree().change_scene_to_file(
    "res://scenes/ui/credits.tscn"
)

	if error != OK:
		print("Failed to load credits scene: ", error)
