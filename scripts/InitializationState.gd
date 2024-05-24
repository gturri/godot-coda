extends BaseState
class_name InitializationState

var context

func _init(context_p):
	context = context_p


func on_card_drawn(card: Card, card_id: int) -> void:
	if context.get_node("CurrentPlayerHand").cards.size() < context.nbCardsInitially:
		context.get_node("AvailableTiles").player_picked_card.rpc(card_id)
		context.update_local_and_remote_hand_with_added_card(card)
		if context.get_node("CurrentPlayerHand").cards.size() == context.nbCardsInitially \
			and context.get_node("OpponentHand").cards.size() < context.nbCardsInitially:
			context.get_node("InfoArea").log_info("Waiting for your opponent to pick his or her cards")
	else:
		context.get_node("InfoArea").log_warning("you already have enough cards")

func on_card_added_to_player_hand() -> void:
	if context.get_node("CurrentPlayerHand").cards.size() == context.nbCardsInitially \
		and context.get_node("OpponentHand").cards.size() == context.nbCardsInitially:
		if context.multiplayer.is_server():
			context.isTurnOfTheServerSidePlayer = randi() % 2
			context.set_active_player.rpc(context.isTurnOfTheServerSidePlayer)
			context.start_new_turn()
