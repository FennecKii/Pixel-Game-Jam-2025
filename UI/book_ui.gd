extends Control

@onready var pages = $PageContainer.get_children()
@onready var left_button = $LeftPageButton
@onready var right_button = $RightPageButton

@onready var option_buttons := [
	$PageContainer/AnswerPage/AnswerButtons/OptionA,
	$PageContainer/AnswerPage/AnswerButtons/OptionB,
	$PageContainer/AnswerPage/AnswerButtons/OptionC
]
@onready var lock_in_button := $PageContainer/AnswerPage/LockInButton

@onready var book_ui = get_node("/root/Main/CanvasLayer/BookUI")  # Adjust path
var book_open := false

func _process(_delta):
	if Input.is_action_just_pressed("toggle_panel"):
		book_open = !book_open
		book_ui.visible = book_open
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if book_open else Input.MOUSE_MODE_CAPTURED)

var current_page := 0

func _ready():
	_update_page()
	left_button.pressed.connect(_on_left_page)
	right_button.pressed.connect(_on_right_page)
	
	for button in option_buttons:
		button.toggled.connect(_on_option_toggled.bind(button))
	lock_in_button.pressed.connect(_on_lock_in_pressed)
	
func _on_left_page():
	if current_page > 0:
		current_page -= 1
		_update_page()

func _on_right_page():
	if current_page < pages.size() - 1:
		current_page += 1
		_update_page()

func _update_page():
	for i in pages.size():
		pages[i].visible = (i == current_page)

func _on_option_toggled(button_pressed: bool, toggled_button: Button):
	if button_pressed:
		for b in option_buttons:
			if b != toggled_button:
				b.button_pressed = false

func _on_lock_in_pressed():
	var selected = null
	for b in option_buttons:
		if b.button_pressed:
			print("Answer locked in: ", b.text)
			return
	print("Please select a ghost first.")
