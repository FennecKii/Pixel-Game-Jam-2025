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

@onready var bell_cb := $PageContainer/GhostChecklistPage/BehaviourChecklist/BellMuted
@onready var ofuda_cb := $PageContainer/GhostChecklistPage/BehaviourChecklist/OfudaBurns
@onready var mirror_cb := $PageContainer/GhostChecklistPage/BehaviourChecklist/MirrorShows

@onready var ghost_labels := {
	"Ghost1": $PageContainer/GhostChecklistPage/GhostDisplay/Ghost1,
	"Ghost2": $PageContainer/GhostChecklistPage/GhostDisplay/Ghost2,
	"Ghost3": $PageContainer/GhostChecklistPage/GhostDisplay/Ghost3
}

const GHOST_BEHAVIORS = {
	"Ghost1": {
		"bell": "nothing",
		"ofuda": "burns",
		"mirror": "shows"
	},
	"Ghost2": {
		"bell": "muted",
		"ofuda": "nothing",
		"mirror": "shows"
	},
	"Ghost3": {
		"bell": "muted",
		"ofuda": "burns",
		"mirror": "nothing"
	}
}

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

	_on_behavior_changed()

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
		pages[i].visible = (i == current_page or i == current_page + 1)

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

func _on_behavior_changed():
	print("Bell Muted Toggled: ", bell_cb.button_pressed)
	print("Ofuda Burns Toggled: ", ofuda_cb.button_pressed)
	print("Mirror Shows Toggled: ", mirror_cb.button_pressed)

	for ghost_name in GHOST_BEHAVIORS:
		var ghost = GHOST_BEHAVIORS[ghost_name]
		var compatible := true

		if bell_cb.button_pressed and ghost["bell"] != "muted":
			compatible = false
		if ofuda_cb.button_pressed and ghost["ofuda"] != "burns":
			compatible = false
		if mirror_cb.button_pressed and ghost["mirror"] != "shows":
			compatible = false

		var label = ghost_labels[ghost_name]
		label.modulate = Color(1, 1, 1, 1) if compatible else Color(0.5, 0.5, 0.5, 1)
		print("Ghost", ghost_name, "is", "visible" if compatible else "greyed out")


func _on_bell_muted_toggled(toggled_on: bool) -> void:
	_on_behavior_changed()

func _on_ofuda_burns_toggled(toggled_on: bool) -> void:
	_on_behavior_changed()

func _on_mirror_shows_toggled(toggled_on: bool) -> void:
	_on_behavior_changed()
