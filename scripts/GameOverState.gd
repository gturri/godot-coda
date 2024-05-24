extends BaseState
class_name GameOverState

func _init(context_p):
	var message = "YOU WON!" if context_p.is_current_player_turn() else "Your opponent won"
	context_p.get_node("InfoArea").log_info("message")
	context_p.get_node("GameOverStatus").set_text(message)
