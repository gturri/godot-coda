extends BaseState
class_name GameOverState

var currentPlayerWon: bool

func _init(context_p, currentPlayerWon_p: bool):
	context = context_p
	currentPlayerWon = currentPlayerWon_p

func on_enter_state() -> void:
	var message = "YOU WON!" if currentPlayerWon else "Your opponent won"
	context.play_audio_won() if currentPlayerWon else context.play_audio_lost()
	context.get_node("InfoArea").log_info("message")
	context.get_node("GameOverStatus").set_text(message)
	context.get_node("OpponentHand").reveal_cards_after_game_over()
