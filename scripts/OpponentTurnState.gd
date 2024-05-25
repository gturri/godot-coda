extends BaseState
class_name OpponentTurnState

func _init(context_p):
	context = context_p

func on_game_ended() -> void:
	context.set_state(GameOverState.new(context, false))
