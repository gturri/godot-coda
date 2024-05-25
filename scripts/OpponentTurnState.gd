extends BaseState
class_name OpponentTurnState

func _init(context_p):
	context = context_p

func on_enter_state() -> void:
	context.get_node("InfoArea").log_info("It is the turn of your opponent")

func on_game_ended() -> void:
	context.set_state(GameOverState.new(context, false))
