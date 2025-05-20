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

@onready var bell_sounds_muted_cb := $PageContainer/GhostChecklistPage/CheckboxContainer/BellSoundsMuted
@onready var bell_sounds_cb := $PageContainer/GhostChecklistPage/CheckboxContainer/BellSounds
@onready var ofuda_burns_cb := $PageContainer/GhostChecklistPage/CheckboxContainer/OfudaBurns
@onready var ofuda_glows_cb := $PageContainer/GhostChecklistPage/CheckboxContainer/OfudaGlows
@onready var mirror_appears_cb := $PageContainer/GhostChecklistPage/CheckboxContainer/MirrorAppears
@onready var mirror_crakcs_cb := $PageContainer/GhostChecklistPage/CheckboxContainer/MirrorCracks

@onready var ghost_labels := {
	"Yuki Onna": $PageContainer/GhostChecklistPage/Ghost1,
	"Onryo": $PageContainer/GhostChecklistPage/Ghost2,
	"Jikininki": $PageContainer/GhostChecklistPage/Ghost3
}

const GHOST_BEHAVIORS = {
	"Yuki Onna": {
		"bell": "nothing",
		"ofuda": ["burns", "glows"],
		"mirror": "appears"
	},
	"Onryo": {
		"bell": "muted",
		"ofuda": "glows",
		"mirror": ["appears", "cracks"],
	},
	"Jikininki": {
		"bell": ["muted", "nothing"],
		"ofuda": "burns",
		"mirror": "cracks"
	}
}

var current_page := 0

func _ready() -> void:
	_update_page()
	left_button.pressed.connect(_on_left_page)
	right_button.pressed.connect(_on_right_page)
	
	_on_behavior_changed()
	
	for button in option_buttons:
		button.toggled.connect(_on_option_toggled.bind(button))
	lock_in_button.pressed.connect(_on_lock_in_pressed)

func _on_left_page() -> void:
	if current_page >= 2:
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_PAGE_FLIP)
		current_page -= 2
		_update_page()

func _on_right_page() -> void:
	if current_page + 2 < pages.size():
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_PAGE_FLIP)
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
		AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS_NOTEBOOK)
		for b in option_buttons:
			if b != toggled_button:
				b.button_pressed = false

func _on_lock_in_pressed() -> void:
	for b_index in range(3):
		if option_buttons[b_index].button_pressed:
			AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS_NOTEBOOK)
			_send_lockin_signal(b_index)
			return
	print("Please select a ghost first.")

func _on_behavior_changed() -> void:
	var compatible := true

	for ghost_name in GHOST_BEHAVIORS:
		var ghost = GHOST_BEHAVIORS[ghost_name]
		compatible = true

		if bell_sounds_muted_cb.button_pressed and not behavior_matches(ghost["bell"], "muted"):
			compatible = false
		if bell_sounds_cb.button_pressed and not behavior_matches(ghost["bell"], "nothing"):
			compatible = false
		if ofuda_burns_cb.button_pressed and not behavior_matches(ghost["ofuda"], "burns"):
			compatible = false
		if ofuda_glows_cb.button_pressed and not behavior_matches(ghost["ofuda"], "glows"):
			compatible = false
		if mirror_appears_cb.button_pressed and not behavior_matches(ghost["mirror"], "appears"):
			compatible = false
		if mirror_crakcs_cb.button_pressed and not behavior_matches(ghost["mirror"], "cracks"):
			compatible = false

		var label = ghost_labels[ghost_name]
		label.modulate = Color(1, 1, 1, 1) if compatible else Color(0.5, 0.5, 0.5, 1)
		print("Ghost", ghost_name, "is", "visible" if compatible else "greyed out")
		
func behavior_matches(ghost_value, expected_value: String) -> bool:
	if typeof(ghost_value) == TYPE_STRING:
		return ghost_value == expected_value
	elif typeof(ghost_value) == TYPE_ARRAY:
		return expected_value in ghost_value
	return false


func _send_lockin_signal(button_index: int) -> void:
	if button_index == Global.GhostNames.YUKIONNA:
		if Global.current_ghost == Global.GhostNames.YUKIONNA:
			get_tree().change_scene_to_file("res://UI/Scenes/win_screen.tscn")
			Global.wincount += 1
		else:
			SignalBus.ghost_alerted.emit()
			lock_in_button.disabled = true
	elif button_index == Global.GhostNames.ONRYO:
		if Global.current_ghost == Global.GhostNames.ONRYO:
			get_tree().change_scene_to_file("res://UI/Scenes/win_screen.tscn")
			Global.wincount += 1
		else:
			SignalBus.ghost_alerted.emit()
			lock_in_button.disabled = true
	elif button_index == Global.GhostNames.JIKININKI:
		if Global.current_ghost == Global.GhostNames.JIKININKI:
			get_tree().change_scene_to_file("res://UI/Scenes/win_screen.tscn")
			Global.wincount += 1
		else:
			SignalBus.ghost_alerted.emit()
			lock_in_button.disabled = true

func _on_ofuda_burns_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CHECKMARK_SCRIBBLE)
	_on_behavior_changed()

func _on_bell_sounds_muted_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CHECKMARK_SCRIBBLE)
	_on_behavior_changed() # Replace with function body.

func _on_bell_sounds_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CHECKMARK_SCRIBBLE)
	_on_behavior_changed() # Replace with function body.

func _on_ofuda_glows_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CHECKMARK_SCRIBBLE)
	_on_behavior_changed() # Replace with function body.

func _on_mirror_appears_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CHECKMARK_SCRIBBLE)
	_on_behavior_changed() # Replace with function body.

func _on_mirror_cracks_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CHECKMARK_SCRIBBLE)
	_on_behavior_changed() # Replace with function body.

func _on_main_menu_pressed() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS_NOTEBOOK)
	get_tree().change_scene_to_file("res://UI/Scenes/main_menu.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_sfx_global(SoundResource.SoundType.BUTTON_PRESS_NOTEBOOK)
