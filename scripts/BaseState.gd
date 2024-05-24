class_name BaseState

var context

func _init(context_p):
	context = context_p

func on_card_drawn(_card: Card, _card_id: int) -> void:
	pass

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
