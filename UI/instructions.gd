extends Control

@onready var page1 = $Page1
@onready var page2 = $Page2

func _ready():
	AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_OPEN)
	page1.visible = true
	page2.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Instructions"):
		AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_OPEN)
		visible = true

func _on_texture_button_pressed():
	AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_PAGE_FLIP)
	page1.visible = false
	page2.visible = true

func _on_back_button_pressed():
	AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_PAGE_FLIP)
	page1.visible = true
	page2.visible = false

func _on_exit_button_pressed():
	AudioManager.play_sfx_global(SoundResource.SoundType.JOURNAL_CLOSE)
	visible = false
