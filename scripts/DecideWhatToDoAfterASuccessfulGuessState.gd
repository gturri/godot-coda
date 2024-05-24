extends BaseState
class_name DecideWhatToDoAfterASuccessfulGuessState

var context
var cardPickedDuringPlayerTurn

func _init(context_p, cardPickedDuringPlayerTurn_p):
	context = context_p
	cardPickedDuringPlayerTurn = cardPickedDuringPlayerTurn_p
	context.get_node("DecideWhatToDoAfterASuccessfulGuessHUD").show()

func on_stop_your_turn_button_pressed():
	var remoteMessage = "Your opponent stopped his or her turns." 
	if cardPickedDuringPlayerTurn:
		context.update_local_and_remote_hand_with_added_card(cardPickedDuringPlayerTurn)
		context.get_node("InfoArea").log_info("The card you picked is added hidden in your hand.")
		remoteMessage += " A new hidden card is added to his or her hand."
	context.log_info_on_other_player.rpc(remoteMessage)
	context.get_node("DecideWhatToDoAfterASuccessfulGuessHUD").hide()
	context.end_of_turn_cleanup()

func on_keep_guessing_button_pressed() -> void:
	context.get_node("DecideWhatToDoAfterASuccessfulGuessHUD").hide()
	context.log_info_on_other_player.rpc("Your opponent decide to guess once more.")
	context.start_phase_guess_opponent_card(cardPickedDuringPlayerTurn)
