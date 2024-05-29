extends Node2D

var isTurnOfTheServerSidePlayer: bool
@export var nbCardsInitially := 4
var state: BaseState

func _ready():
	$GuessACardHUD.hide()
	$DecideWhatToDoAfterASuccessfulGuessHUD.hide()
	$InfoArea.log_info("Each player must pick " + str(nbCardsInitially) + " cards")
	set_state(InitializationState.new(self))

func set_state(newState: BaseState) -> void:
	state = newState
	state.on_enter_state()

func on_card_drawn(card: Card, card_id: int, cardPosition: Vector2) -> void:
	state.on_card_drawn(card, card_id, cardPosition)

func update_local_and_remote_hand_with_added_card(card: Card, cardPositionOnBoardForLocalPlayer: Vector2, cardPositionOnBoardForRemotePlayer: Vector2) -> void:
	$CurrentPlayerHand.add_card(card, cardPositionOnBoardForLocalPlayer)
	$OpponentHand.add_card_remotely.rpc(CardSerializer.serialize_card(card), cardPositionOnBoardForRemotePlayer)

func on_selected_opponent_card(cardId) -> void:
	state.on_selected_opponent_card(cardId)

func on_card_added_to_player_hand() -> void:
	state.on_card_added_to_player_hand()

@rpc("authority", "call_remote", "reliable")
func set_active_player(isTurnOfTheServerSidePlayer_p: bool) -> void:
	isTurnOfTheServerSidePlayer = isTurnOfTheServerSidePlayer_p
	start_new_turn()

func is_current_player_turn() -> bool:
	return multiplayer.is_server() == isTurnOfTheServerSidePlayer

@rpc("any_peer", "call_local", "reliable")
func change_player_and_start_new_turn() -> void:
	isTurnOfTheServerSidePlayer = not isTurnOfTheServerSidePlayer
	start_new_turn()

func start_new_turn() -> void:
	if not is_current_player_turn():
		set_state(OpponentTurnState.new(self))
	else:
		set_state(PickCardOnTheTableState.new(self))

func on_guess_button_pressed() -> void:
	state.on_guess_button_pressed()

@rpc("any_peer", "call_remote", "reliable")
func game_ended() -> void:
	state.on_game_ended()

@rpc("any_peer", "call_remote", "reliable")
func opponent_picked_card_at_the_beginning_of_the_turn(serializedCard: String, initialPosition: Vector2) -> void:
	state.opponent_picked_card_at_the_beginning_of_the_turn(CardSerializer.deserialize_card(serializedCard), initialPosition)

@rpc("any_peer", "call_remote", "reliable")
func opponent_guessed_a_card(cardId: int) -> void:
	$InfoArea.log_info("Your card in position " + str(cardId+1) + " has been guessed!")
	$CurrentPlayerHand.make_card_visible(cardId)

func on_keep_guessing_button_pressed() -> void:
	state.on_keep_guessing_button_pressed()

func on_stop_your_turn_button_pressed() -> void:
	state.on_stop_your_turn_button_pressed()

@rpc("any_peer", "call_remote", "reliable")
func log_info_on_other_player(message: String) -> void:
	$InfoArea.log_info(message)
