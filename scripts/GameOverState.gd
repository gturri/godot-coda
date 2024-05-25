extends BaseState
class_name GameOverState

func _init(context_p):
	context = context_p

func on_enter_state() -> void:
	var message = "YOU WON!" if context.is_current_player_turn() else "Your opponent won"
	context.get_node("InfoArea").log_info("message")
	context.get_node("GameOverStatus").set_text(message)
