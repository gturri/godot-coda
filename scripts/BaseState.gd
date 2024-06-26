class_name BaseState

var context

func _init(context_p):
	context = context_p

func on_enter_state() -> void:
	pass

func on_card_drawn(_card: Card, _card_id: int, _cardPosition: Vector2) -> void:
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

func on_game_ended() -> void:
	pass

func opponent_picked_card_at_the_beginning_of_the_turn(_card: Card, _initialPosition: Vector2) -> void:
	pass

func input(_event) -> void:
	pass
