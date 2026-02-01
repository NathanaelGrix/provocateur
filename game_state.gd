extends Node



enum State {
	INTRO,
	SNEAKY,
	DISGUISED,
	FIGHT,
	END
}

signal state_changed(new_state: State)

var current_state: State = State.INTRO

func set_state(new_state: State) -> void:
	if new_state == current_state:
		return

	current_state = new_state
	emit_signal("state_changed", current_state)
