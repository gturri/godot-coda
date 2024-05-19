extends Node2D

var isInitializationPhase := true
var isTurnOfTheServerSidePlayer: bool
@export var nbCardsInitially := 4

func _ready():
	$InfoArea.log_info("Each player must pick " + str(nbCardsInitially) + " cards")

func on_card_drawn(card: Card, card_id: int):
	if isInitializationPhase:
		if $CurrentPlayerHand.cards.size() < nbCardsInitially:
			$AvailableTiles.player_picked_card.rpc(card_id)
			$CurrentPlayerHand.add_card(card)
			$OpponentHand.add_card_remotely.rpc(CardSerializer.serialize_card(card))
			if $CurrentPlayerHand.cards.size() == nbCardsInitially and $OpponentHand.cards.size() < nbCardsInitially:
				$InfoArea.log_info("Waiting for your opponent to pick his or her cards")
		else:
			$InfoArea.log_warning("you already have enough cards")
			return
	else:
		pass #TODO

func on_card_added_to_player_hand():
	if $CurrentPlayerHand.cards.size() == nbCardsInitially \
		and $OpponentHand.cards.size() == nbCardsInitially:
		isInitializationPhase = false
		print("initialization completed")
		if multiplayer.is_server():
			isTurnOfTheServerSidePlayer = randi() % 2
			set_active_player.rpc(isTurnOfTheServerSidePlayer)
			log_active_player()

@rpc("authority", "call_remote", "reliable")
func set_active_player(isTurnOfTheServerSidePlayer_p: bool) -> void:
	isTurnOfTheServerSidePlayer = isTurnOfTheServerSidePlayer_p
	log_active_player()

func log_active_player() -> void:
	var isCurrentPlayerTurn = (multiplayer.is_server() == isTurnOfTheServerSidePlayer)
	$InfoArea.log_info("It is your turn" if isCurrentPlayerTurn else "It is the turn of your opponent")
