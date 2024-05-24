extends BaseState
class_name PickCardOnTheTableState

func _init(context_p):
	context = context_p
	context.get_node("InfoArea").log_info("Pick a card on the table")

func on_card_drawn(card: Card, card_id: int) -> void:
	context.get_node("AvailableTiles").player_picked_card.rpc(card_id)
	context.currentState = GuessOpponentCardState.new(context, card)
