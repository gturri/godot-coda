class_name PickCardOnTheTableState

var context

func _init(context_p):
	context = context_p
	context.get_node("InfoArea").log_info("Pick a card on the table")

func on_card_drawn(card: Card, card_id: int) -> void:
	context.get_node("AvailableTiles").player_picked_card.rpc(card_id)
	context.currentState = GuessOpponentCardState.new(context, card)

func on_selected_opponent_card(_cardId) -> void:
	pass

func on_card_added_to_player_hand() -> void:
	pass

func on_guess_button_pressed() -> void:
	pass

func on_stop_your_turn_button_pressed() -> void:
	pass

func on_keep_guessing_button_pressed() -> void:
	pass
