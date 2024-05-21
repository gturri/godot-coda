extends Node2D

var isTurnOfTheServerSidePlayer: bool
@export var nbCardsInitially := 4

enum Phase {INITIALIZATION, OPPONENT_TURN, PICK_CARD_ON_THE_TABLE, GUESS_OPPONENT_CARD, DECIDE_WHAT_TO_DO_WITH_PICKED_CARD}
var phase := Phase.INITIALIZATION
var selectedOpponentCardId
var cardPickedDuringPlayerTurn

func _ready():
	$GuessACardHUD.hide()
	$InfoArea.log_info("Each player must pick " + str(nbCardsInitially) + " cards")

func on_card_drawn(card: Card, card_id: int):
	if phase == Phase.INITIALIZATION:
		if $CurrentPlayerHand.cards.size() < nbCardsInitially:
			$AvailableTiles.player_picked_card.rpc(card_id)
			update_local_and_remote_hand_with_added_card(card)
			if $CurrentPlayerHand.cards.size() == nbCardsInitially and $OpponentHand.cards.size() < nbCardsInitially:
				$InfoArea.log_info("Waiting for your opponent to pick his or her cards")
		else:
			$InfoArea.log_warning("you already have enough cards")
			return
	elif phase == Phase.PICK_CARD_ON_THE_TABLE:
		$AvailableTiles.player_picked_card.rpc(card_id)
		start_phase_guess_opponent_card(card)

func update_local_and_remote_hand_with_added_card(card: Card) -> void:
	$CurrentPlayerHand.add_card(card)
	$OpponentHand.add_card_remotely.rpc(CardSerializer.serialize_card(card))

func on_selected_opponent_card(cardId) -> void:
	if phase == Phase.GUESS_OPPONENT_CARD:
		selectedOpponentCardId = cardId
		$OpponentHand.set_opponent_selected_card(cardId)

func on_card_added_to_player_hand():
	if phase == Phase.INITIALIZATION \
		and $CurrentPlayerHand.cards.size() == nbCardsInitially \
		and $OpponentHand.cards.size() == nbCardsInitially:
		print("initialization completed")
		if multiplayer.is_server():
			isTurnOfTheServerSidePlayer = randi() % 2
			set_active_player.rpc(isTurnOfTheServerSidePlayer)
			start_new_turn()

@rpc("authority", "call_remote", "reliable")
func set_active_player(isTurnOfTheServerSidePlayer_p: bool) -> void:
	isTurnOfTheServerSidePlayer = isTurnOfTheServerSidePlayer_p
	start_new_turn()

func log_active_player() -> void:
	$InfoArea.log_info("It is your turn" if is_current_player_turn() else "It is the turn of your opponent")

func is_current_player_turn() -> bool:
	return multiplayer.is_server() == isTurnOfTheServerSidePlayer

@rpc("any_peer", "call_local", "reliable")
func change_player_and_start_new_turn() -> void:
	isTurnOfTheServerSidePlayer = not isTurnOfTheServerSidePlayer
	start_new_turn()

func start_new_turn() -> void:
	log_active_player()
	if not is_current_player_turn():
		phase = Phase.OPPONENT_TURN
	elif not $AvailableTiles.is_empty():
		phase = Phase.PICK_CARD_ON_THE_TABLE
		$InfoArea.log_info("Pick a card on the table")
	else:
		start_phase_guess_opponent_card(null)

func start_phase_guess_opponent_card(card) -> void:
	phase = Phase.GUESS_OPPONENT_CARD
	cardPickedDuringPlayerTurn = card
	if card:
		$PickedCard.show()
		$PickedCard.set_texture($AvailableTiles.get_card_texture(card))
	$GuessACardHUD.show()
	$InfoArea.log_info("Click the card in your opponent hand that you want to guess and enter a number")
	# TODO: display the Controls to select a number and validate


func on_guess_button_pressed() -> void:
	if phase != Phase.GUESS_OPPONENT_CARD: # The button should not be displayed, but it seems safer to check
		return
	if selectedOpponentCardId == null:
		$InfoArea.log_warning("you must select the card you want to guess in your opponent hand")
		return
	var guessedCard: Card = $OpponentHand.cards[selectedOpponentCardId]
	if guessedCard.isVisible:
		$InfoArea.log_warning("you must select a card not known yet!")
		return
	if not $GuessACardHUD/GuessTheNumberInput.text.is_valid_int():
		$InfoArea.log_warning("you must guess a number")
		return
	var guessedValue :int = $GuessACardHUD/GuessTheNumberInput.text.to_int()
	if guessedValue < 1 or guessedValue > $AvailableTiles.maxValue:
		$InfoArea.log_warning("The value must be in the range [1, " + str($AvailableTiles.maxValue) + "]")
		return

	if guessedValue == guessedCard.value+1:
		guessedCard.isVisible = true
		$OpponentHand.paint()
		opponent_guessed_a_card.rpc(selectedOpponentCardId)
		# TODO
	else:
		opponent_failed_a_guess.rpc(selectedOpponentCardId, guessedValue)
		$InfoArea.log_info("Your guess was incorrect. Your turn ends.")
		if cardPickedDuringPlayerTurn:
			$InfoArea.log_info("The card you picked is added visible in your hand.")
			cardPickedDuringPlayerTurn.isVisible = true
			update_local_and_remote_hand_with_added_card(cardPickedDuringPlayerTurn)
		end_of_turn_cleanup()

func end_of_turn_cleanup() -> void:
	selectedOpponentCardId = null
	$OpponentHand.clear_opponent_selected_card()
	cardPickedDuringPlayerTurn = null
	$PickedCard.hide()
	$GuessACardHUD.hide()
	change_player_and_start_new_turn.rpc()

@rpc("any_peer", "call_remote", "reliable")
func opponent_guessed_a_card(cardId: int) -> void:
	$InfoArea.log_info("Your card in position " + str(cardId+1) + " has been guessed!")
	$CurrentPlayerHand.cards[cardId].isVisible = true
	$CurrentPlayerHand.paint()

@rpc("any_peer", "call_remote", "reliable")
func opponent_failed_a_guess(cardId: int, cardValue: int) -> void:
	$InfoArea.log_info("Your opponent tried saying that your card in position " + str(cardId + 1) + " is " + str(cardValue) + \
	 ". He or she missed (actual value: " + str($CurrentPlayerHand.cards[cardId].value+1) + ")")
