extends BaseState
class_name PickCardOnTheTableState

func _init(context_p):
	context = context_p

func on_enter_state() -> void:
	context.get_node("InfoArea").log_info("It is your turn")
	if not context.get_node("AvailableTiles").is_empty():
		context.get_node("InfoArea").log_info("Pick a card on the table")
	else:
		context.set_state(GuessOpponentCardState.new(context, null))

func on_card_drawn(card: Card, card_id: int) -> void:
	context.get_node("AvailableTiles").player_picked_card.rpc(card_id)
	context.set_state(GuessOpponentCardState.new(context, card))
