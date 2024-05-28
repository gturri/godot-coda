extends BaseState
class_name DecideWhatToDoAfterASuccessfulGuessState

var onHoldGuessOpponentCardState: GuessOpponentCardState

func _init(context_p, onHoldGuessOpponentCardState_p: GuessOpponentCardState):
	context = context_p
	onHoldGuessOpponentCardState = onHoldGuessOpponentCardState_p

func on_enter_state() -> void:
	context.get_node("DecideWhatToDoAfterASuccessfulGuessHUD").show()

func on_stop_your_turn_button_pressed():
	var remoteMessage = "Your opponent stopped his or her turns." 
	if onHoldGuessOpponentCardState.cardPickedDuringPlayerTurn:
		context.update_local_and_remote_hand_with_added_card(onHoldGuessOpponentCardState.cardPickedDuringPlayerTurn, context.get_node("PickedCardOverviewPosition").position)
		context.get_node("InfoArea").log_info("The card you picked is added hidden in your hand.")
		remoteMessage += " A new hidden card is added to his or her hand."
	context.log_info_on_other_player.rpc(remoteMessage)
	context.get_node("DecideWhatToDoAfterASuccessfulGuessHUD").hide()
	context.change_player_and_start_new_turn.rpc()

func on_keep_guessing_button_pressed() -> void:
	context.get_node("DecideWhatToDoAfterASuccessfulGuessHUD").hide()
	context.log_info_on_other_player.rpc("Your opponent decide to guess once more.")
	context.set_state(onHoldGuessOpponentCardState)
