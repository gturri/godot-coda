class_name PlayerHand

var cards: Array[Card] = []

func add_card(card: Card) -> void:
	cards.append(card)
	cards.sort_custom(Card.compare)
