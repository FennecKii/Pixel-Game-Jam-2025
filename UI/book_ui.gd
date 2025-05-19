extends Control

@onready var pages := [
	$PageContainer/Page1Blank,
	$PageContainer/Page2_Menu,
	$PageContainer/Page3_Story,
	$PageContainer/Page4_Story,
	$PageContainer/Page5_Story,
	$PageContainer/Page6_Story,
	$PageContainer/GhostChecklistPage,
	$PageContainer/AnswerPage
]


@onready var left_button = $LeftPageButton
@onready var right_button = $RightPageButton

@onready var option_buttons := [
	$PageContainer/AnswerPage/AnswerButtons/OptionA,
	$PageContainer/AnswerPage/AnswerButtons/OptionB,
	$PageContainer/AnswerPage/AnswerButtons/OptionC
]
@onready var lock_in_button := $PageContainer/AnswerPage/LockInButton

var book_open := false

@onready var bell_cb := $PageContainer/GhostChecklistPage/BellMuted
@onready var ofuda_cb := $PageContainer/GhostChecklistPage/OfudaBurns
@onready var mirror_cb := $PageContainer/GhostChecklistPage/MirrorShows

@onready var ghost_labels := {
	"Yuki Onna": $PageContainer/GhostChecklistPage/Ghost1,
	"Onryo": $PageContainer/GhostChecklistPage/Ghost2,
	"Jikininki": $PageContainer/GhostChecklistPage/Ghost3
}

const GHOST_BEHAVIORS = {
	"Yuki Onna": {
		"bell": "nothing",
		"ofuda": "burns",
		"mirror": "shows"
	},
	"Onryo": {
		"bell": "muted",
		"ofuda": "nothing",
		"mirror": "shows"
	},
	"Jikininki": {
		"bell": "muted",
		"ofuda": "burns",
		"mirror": "nothing"
	}
}

var current_page := 0

func _ready() -> void:
	_update_page()
	left_button.pressed.connect(_on_left_page)
	right_button.pressed.connect(_on_right_page)

	print("Left button is: ", left_button)
	left_button.pressed.connect(func():
		print("LEFT BUTTON WORKS!")
	)


	_on_behavior_changed()

	for button in option_buttons:
		button.toggled.connect(_on_option_toggled.bind(button))
	lock_in_button.pressed.connect(_on_lock_in_pressed)
	
	
	
func _on_left_page() -> void:
	if current_page >= 2:
		current_page -= 2
		_update_page()

func _on_right_page() -> void:
	if current_page + 2 < pages.size():
		current_page += 2
		_update_page()


func _update_page() -> void:
	for i in range(pages.size()):
		pages[i].visible = false

	if current_page < pages.size():
		pages[current_page].visible = true
	if current_page + 1 < pages.size():
		pages[current_page + 1].visible = true

	left_button.disabled = current_page == 0
	right_button.disabled = current_page + 2 >= pages.size()
	
	# make page button invisible when on first or last page
	left_button.visible = current_page != 0
	right_button.visible = current_page + 2 < pages.size()




func _on_option_toggled(button_pressed: bool, toggled_button: Button) -> void:
	if button_pressed:
		for b in option_buttons:
			if b != toggled_button:
				b.button_pressed = false

func _on_lock_in_pressed() -> void:
	for b_index in range(3):
		if option_buttons[b_index].button_pressed:
			_send_lockin_signal(b_index)
			return
	print("Please select a ghost first.")

func _on_behavior_changed() -> void:
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

func _send_lockin_signal(button_index: int) -> void:
	if button_index == Global.GhostNames.YUKIONNA:
		if Global.current_ghost == Global.GhostNames.YUKIONNA:
			print("Player won")
		else:
			SignalBus.ghost_alerted.emit()
	elif button_index == Global.GhostNames.ONRYO:
		if Global.current_ghost == Global.GhostNames.ONRYO:
			print("Player won")
		else:
			SignalBus.ghost_alerted.emit()
	elif button_index == Global.GhostNames.JIKININKI:
		if Global.current_ghost == Global.GhostNames.JIKININKI:
			print("Player won")
		else:
			SignalBus.ghost_alerted.emit()

func _on_bell_muted_toggled(toggled_on: bool) -> void:
	_on_behavior_changed()

func _on_ofuda_burns_toggled(toggled_on: bool) -> void:
	_on_behavior_changed()

func _on_mirror_shows_toggled(toggled_on: bool) -> void:
	_on_behavior_changed()
	
func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
