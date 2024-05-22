A 2 players cards game made with [Godot](https://godotengine.org/).

# How to install

1. First, download the [Godot Engine](https://godotengine.org/download/) (nb: this has been developed and tested with godot 4.2)
2. Then clone this repo
3. Launch the Godot Engine and import this project (import the file `project.godot`)
4. When the project is opened, start it by pressing `F5` in the Godot Engine

It's a 2 players game, so you need to launch two instances.
- On one instance click `Host game` and wait until the other connects
- On the other instance enter the IP of the host and then click on `Connect to`

nb: it uses the port 6666 and uses UDP (in case you need to open some firewall port or configure some port redirection on your router)

# How to play
## The concept

There are 11 yellow cards (numbered from 1 to 11) and 11 green cards (numbered from 1 to 11).

Each player starts with 4 random cards. The cards are sorted by increasing order in the player hands (If you have two cards with the same value, the green one is considered the smaller one).

The goal is to guess all the cards of your opponent.

## How it works in practice

1. First, each player pick 4 cards at random on the board. Once it's done, the player who start is picked randomly
2. At your turn:
   1. Pick a card on the table. You can see it, but it does not go in your hand yet
   2. Try to guess a card in the hand of your opponent (select a card in his or her hand, enter a number, and guess)
   3. If you guess correctly, you can choose to either guess another card (ie: go back to the previous step) or stop your turn. If you decide to stop your turn, the card you picked at the beginning of your turn goes in your hand, hidden (so your opponent has more cards to guess)
   4. If your guess is wrong then your turn ends, and your card goes in your hand, visible (so your opponent has more information to guess your remaining cards)
3. The game stops when a player guessed all the cards of his or her opponent

# Where does this game come from

A friend described those rules to me. It seems it come from an actual card game. However, I have no clues about the name of the original game.
