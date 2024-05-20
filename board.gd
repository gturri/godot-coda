extends Node2D

var isTurnOfTheServerSidePlayer: bool
@export var nbCardsInitially := 4

enum Phase {INITIALIZATION, OPPONENT_TURN, PICK_CARD_ON_THE_TABLE, GUESS_OPPONENT_CARD, DECIDE_WHAT_TO_DO_WITH_PICKED_CARD}
var phase := Phase.INITIALIZATION

func _ready():
	$InfoArea.log_info("Each player must pick " + str(nbCardsInitially) + " cards")

func on_card_drawn(card: Card, card_id: int):
	if phase == Phase.INITIALIZATION:
		if $CurrentPlayerHand.cards.size() < nbCardsInitially:
			$AvailableTiles.player_picked_card.rpc(card_id)
			$CurrentPlayerHand.add_card(card)
			$OpponentHand.add_card_remotely.rpc(CardSerializer.serialize_card(card))
			if $CurrentPlayerHand.cards.size() == nbCardsInitially and $OpponentHand.cards.size() < nbCardsInitially:
				$InfoArea.log_info("Waiting for your opponent to pick his or her cards")
		else:
			$InfoArea.log_warning("you already have enough cards")
			return
	elif phase == Phase.PICK_CARD_ON_THE_TABLE:
		$AvailableTiles.player_picked_card.rpc(card_id)
		start_phase_guess_opponent_card(card)

func on_card_added_to_player_hand():
	if $CurrentPlayerHand.cards.size() == nbCardsInitially \
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
	if card:
		$PickedCard.show()
		$PickedCard.set_texture($AvailableTiles.get_card_texture(card))
	$InfoArea.log_info("Click the card in your opponent hand that you want to guess and enter a number")
	# TODO: display the Controls to select a number and validate
