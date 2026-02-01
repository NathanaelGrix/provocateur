extends AudioStreamPlayer

@onready var music: AudioStreamPlaybackInteractive = self.get_stream_playback()

func _ready():
	GameState.state_changed.connect(_on_state_changed)
	_play_intro()

func _on_state_changed(state: GameState.State) -> void:
	match state:
		GameState.State.INTRO:
			_play_intro()
		GameState.State.SNEAKY:
			_play_sneaky()
		GameState.State.DISGUISED:
			_play_disguised()
		GameState.State.FIGHT:
			_play_fight()
		GameState.State.END:
			_play_end()

func _play_intro():
	music.switch_to_clip_by_name(&"Intro")

func _play_sneaky():
	music.switch_to_clip_by_name(&"Sneaky")

func _play_disguised():
	music.switch_to_clip_by_name(&"Disguised")

func _play_fight():
	music.switch_to_clip_by_name(&"Fight")

func _play_end():
	music.switch_to_clip_by_name(&"End")
