extends Node2D

var isTurnOfTheServerSidePlayer: bool
@export var nbCardsInitially := 4
var currentState

func _ready():
	$GuessACardHUD.hide()
	$DecideWhatToDoAfterASuccessfulGuessHUD.hide()
	$InfoArea.log_info("Each player must pick " + str(nbCardsInitially) + " cards")
	currentState = InitializationState.new(self)

func on_card_drawn(card: Card, card_id: int) -> void:
	currentState.on_card_drawn(card, card_id)

func update_local_and_remote_hand_with_added_card(card: Card) -> void:
	$CurrentPlayerHand.add_card(card)
	$OpponentHand.add_card_remotely.rpc(CardSerializer.serialize_card(card))

func on_selected_opponent_card(cardId) -> void:
	currentState.on_selected_opponent_card(cardId)

func on_card_added_to_player_hand() -> void:
	currentState.on_card_added_to_player_hand()

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
		currentState = OpponentTurnState.new(self)
	elif not $AvailableTiles.is_empty():
		currentState = PickCardOnTheTableState.new(self)
	else:
		start_phase_guess_opponent_card(null)

func start_phase_guess_opponent_card(card) -> void:
	currentState = GuessOpponentCardState.new(self, card)

func on_guess_button_pressed() -> void:
	currentState.on_guess_button_pressed()

@rpc("any_peer", "call_local", "reliable")
func active_player_won() -> void:
	currentState = GameOverState.new(self)

func end_of_turn_cleanup() -> void: #TODO: shall this remain here?
	$OpponentHand.clear_opponent_selected_card()
	$PickedCard.hide()
	$GuessACardHUD.hide()
	change_player_and_start_new_turn.rpc()

@rpc("any_peer", "call_remote", "reliable")
func opponent_guessed_a_card(cardId: int) -> void:
	$InfoArea.log_info("Your card in position " + str(cardId+1) + " has been guessed!")
	$CurrentPlayerHand.cards[cardId].isVisible = true
	$CurrentPlayerHand.paint()

func on_keep_guessing_button_pressed() -> void:
	currentState.on_keep_guessing_button_pressed()

func on_stop_your_turn_button_pressed() -> void:
	currentState.on_stop_your_turn_button_pressed()

@rpc("any_peer", "call_remote", "reliable")
func log_info_on_other_player(message: String) -> void:
	$InfoArea.log_info(message)
