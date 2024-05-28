extends BaseState
class_name GuessOpponentCardState

var cardPickedDuringPlayerTurn
var selectedOpponentCardId

func _init(context_p, cardPickedDuringPlayerTurn_p):
	context = context_p
	cardPickedDuringPlayerTurn = cardPickedDuringPlayerTurn_p

func on_enter_state():
	if cardPickedDuringPlayerTurn:
		context.get_node("PickedCard").show()
		context.get_node("PickedCard").set_texture(context.get_node("AvailableTiles").get_card_texture(cardPickedDuringPlayerTurn))
	context.get_node("GuessACardHUD").show()
	context.get_node("InfoArea").log_info("Click the card in your opponent hand that you want to guess and enter a number")

func on_selected_opponent_card(cardId) -> void:
	selectedOpponentCardId = cardId
	context.get_node("OpponentHand").set_opponent_selected_card(cardId)

func on_guess_button_pressed() -> void:
	if selectedOpponentCardId == null:
		context.get_node("InfoArea").log_warning("you must select the card you want to guess in your opponent hand")
		return
	var guessedCard: Card = context.get_node("OpponentHand").cards[selectedOpponentCardId]
	if guessedCard.isVisible:
		context.get_node("InfoArea").log_warning("you must select a card not known yet!")
		return
	if not context.get_node("GuessACardHUD/GuessTheNumberInput").text.is_valid_int():
		context.get_node("InfoArea").log_warning("you must guess a number")
		return
	var guessedValue :int = context.get_node("GuessACardHUD/GuessTheNumberInput").text.to_int()
	if guessedValue < 1 or guessedValue > context.get_node("AvailableTiles").maxValue:
		context.get_node("InfoArea").log_warning("The value must be in the range [1, " + str(context.get_node("AvailableTiles").maxValue) + "]")
		return

	if guessedValue == guessedCard.value+1:
		__on_correct_guess(selectedOpponentCardId)
	else:
		__on_bad_guess(guessedValue, guessedCard)

func __on_correct_guess(selectedOpponentCardId: int) -> void:
	context.get_node("OpponentHand").make_card_visible(selectedOpponentCardId)
	context.opponent_guessed_a_card.rpc(selectedOpponentCardId)
	if not context.get_node("OpponentHand").has_hidden_cards():
		context.game_ended.rpc()
		context.set_state(GameOverState.new(context, true))
		return
	start_decideWhatToDo_phase()

func __on_bad_guess(guessedValue: int, guessedCard: Card) -> void:
	context.log_info_on_other_player.rpc("Your opponent tried saying that your card in position " + str(selectedOpponentCardId + 1) + " is " + str(guessedValue) + \
		 ". He or she missed (actual value: " + str(guessedCard.value+1) + ")")
	context.get_node("InfoArea").log_info("Your guess was incorrect. Your turn ends.")
	if cardPickedDuringPlayerTurn:
		context.get_node("InfoArea").log_info("The card you picked is added visible in your hand.")
		cardPickedDuringPlayerTurn.isVisible = true
		context.update_local_and_remote_hand_with_added_card(cardPickedDuringPlayerTurn, context.get_node("PickedCard").position)
	context.change_player_and_start_new_turn.rpc()

func start_decideWhatToDo_phase() -> void:
	context.get_node("GuessACardHUD").hide()
	context.set_state(DecideWhatToDoAfterASuccessfulGuessState.new(context, self))

func _notification(notif):
	if notif == NOTIFICATION_PREDELETE: # Destructor; see https://docs.godotengine.org/en/4.2/tutorials/best_practices/godot_notifications.html
		context.get_node("PickedCard").hide()
		context.get_node("GuessACardHUD").hide()
		context.get_node("OpponentHand").clear_opponent_selected_card()
