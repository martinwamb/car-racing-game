extends CanvasLayer

# Shown when the car hits a question zone checkpoint.
# Freezes the car, shows a question, awards coins on correct answer.

signal answered(correct: bool, coins_earned: int)

@onready var question_label: Label = $Panel/VBox/QuestionLabel
@onready var buttons: Array = [
	$Panel/VBox/Answers/Btn0,
	$Panel/VBox/Answers/Btn1,
	$Panel/VBox/Answers/Btn2,
	$Panel/VBox/Answers/Btn3,
]
@onready var explanation_label: Label = $Panel/VBox/ExplanationLabel
@onready var coin_label: Label = $Panel/VBox/CoinLabel
@onready var continue_btn: Button = $Panel/VBox/ContinueBtn

var _current_question: Dictionary = {}
var _difficulty: int = 1

func _ready() -> void:
	for i in range(buttons.size()):
		buttons[i].pressed.connect(_on_answer_pressed.bind(i))
	continue_btn.pressed.connect(_on_continue_pressed)

func show_question(question: Dictionary) -> void:
	_current_question = question
	_difficulty = question.get("difficulty", 1)
	explanation_label.hide()
	coin_label.hide()
	continue_btn.hide()

	question_label.text = question.get("question", "")
	var answers: Array = question.get("answers", [])
	for i in range(buttons.size()):
		if i < answers.size():
			buttons[i].text = answers[i]
			buttons[i].disabled = false
			buttons[i].show()
		else:
			buttons[i].hide()

	visible = true

func _on_answer_pressed(index: int) -> void:
	var correct_index: int = _current_question.get("correct", 0)
	var is_correct = (index == correct_index)

	# Disable all buttons after answering
	for btn in buttons:
		btn.disabled = true

	explanation_label.text = _current_question.get("explanation", "")
	explanation_label.show()

	var coins_earned = 0
	if is_correct:
		coins_earned = CoinSystem.award_question_coins(_difficulty)
		coin_label.text = "+ %d coins!" % coins_earned
		coin_label.modulate = Color.GREEN
	else:
		coin_label.text = "Not quite — keep learning!"
		coin_label.modulate = Color.ORANGE_RED

	coin_label.show()
	continue_btn.show()
	answered.emit(is_correct, coins_earned)

func _on_continue_pressed() -> void:
	visible = false
