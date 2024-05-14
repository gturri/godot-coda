class_name PlayerHand

var cards: Array[Card] = []

func addCard(card: Card) -> void:
	cards.append(card)
	cards.sort_custom(Callable(Card, "sort"))
