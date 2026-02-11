extends Control

@onready var references_text = $VBoxContainer/ScrollContainer/ReferencesText
@onready var back_to_menu_button = $VBoxContainer/BackToMenuButton

const HOVER_SCALE = Vector2(1.15, 1.15)
const NORMAL_SCALE = Vector2(1.0, 1.0)
const SCALE_DURATION = 0.2

var references: String = """Former FBI Agent Explains How to Read Body Language | Tradecraft | WIRED. (n.d.). YouTube.

	https://www.youtube.com/watch?v=4jwUXV4QaTw

Liu, L., Gao, L., Lei, W., Ma, F., Lin, X., & Wang, J. (2023). A survey on deep multi-modal learning for body language recognition and generation. arXiv.

	https://arxiv.org/abs/2308.08849

Mental Health First Aid. (2018, June 18). 6 ways to improve your non-verbal communication skills.

	https://mentalhealthfirstaid.org/news/6-ways-to-improve-your-non-verbal-communication-skills/

Patterson, M. L., Fridlund, A. J., & Crivelli, C. (2023). Four misconceptions about nonverbal communication. Perspectives on Psychological Science, 18(6), 1388–1411.

	https://doi.org/10.1177/17456916221148142

Raising Children Network. (2024, June 17). Nonverbal communication: Body language and tone of voice.

	https://raisingchildren.net.au/toddlers/connecting-communicating/communicating/nonverbal-communication

Segal, J., Smith, M., Robinson, L., & Boose, G. (n.d.). Body language and nonverbal communication: Communicating without words. HelpGuide.

	https://www.helpguide.org/relationships/communication/nonverbal-communication

The Power of Deciphering People's Nonverbal Cues. (n.d.). YouTube.

	https://www.youtube.com/watch?v=4RoMQpP7-TQ

Urakami, J., & Seaborn, K. (2023). Nonverbal cues in human-robot interaction: A communication studies perspective. arXiv.

	https://arxiv.org/abs/2304.11293

Verywell Mind. (2025, January 30). 9 types of nonverbal communication.

	https://www.verywellmind.com/types-of-nonverbal-communication-2795397

What Is Non-Verbal Communication? (n.d.). YouTube.

	https://www.youtube.com/watch?v=HxDqYEl20hI"""

func _ready() -> void:
	if back_to_menu_button:
		back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
		back_to_menu_button.mouse_entered.connect(_on_back_to_menu_mouse_entered)
		back_to_menu_button.mouse_exited.connect(_on_back_to_menu_mouse_exited)
	
	if references_text:
		references_text.text = references
		references_text.visible = true

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_back_to_menu_mouse_entered() -> void:
	_scale_button(back_to_menu_button, HOVER_SCALE)

func _on_back_to_menu_mouse_exited() -> void:
	_scale_button(back_to_menu_button, NORMAL_SCALE)

func _scale_button(button: Button, target_scale: Vector2) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", target_scale, SCALE_DURATION)
