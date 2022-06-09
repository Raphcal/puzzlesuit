#  PuzzleSuit
PuzzleSuit is a tile-matching videogame where you make tiles disappear by making Poker hands.

![Game start](./Preview/puzzlesuit-start.gif)

You can make combo to send chips to your opponent.

![Combo](./Preview/puzzlesuit-combo.gif)

A big combo can KO your opponent in one shot!

![A lot of chips](./Preview/puzzlesuit-chips.gif)

PuzzleSuit is written in Swift and can only be played on macOS.

## How to play

### Tiles
There are 32 tiles in total. 8 ranks ranging from ace to 5, jack, queen and king in each of the 4 french suits:

- Clubs
  
  ![Ace of club](./Preview/Club%20Ace.png)
  ![Two of club](./Preview/Club%202.png)
  ![Three of club](./Preview/Club%203.png)
  ![Four of club](./Preview/Club%204.png)
  ![Five of club](./Preview/Club%205.png)
  ![Jack of club](./Preview/Club%20Jack.png)
  ![Queen of club](./Preview/Club%20Queen.png)
  ![King of club](./Preview/Club%20King.png)

- Diamonds
  
  ![Ace of diamond](./Preview/Diamond%20Ace.png)
  ![Two of diamond](./Preview/Diamond%202.png)
  ![Three of diamond](./Preview/Diamond%203.png)
  ![Four of diamond](./Preview/Diamond%204.png)
  ![Five of diamond](./Preview/Diamond%205.png)
  ![Jack of diamond](./Preview/Diamond%20Jack.png)
  ![Queen of diamond](./Preview/Diamond%20Queen.png)
  ![King of diamond](./Preview/Diamond%20King.png)

- Hearts
  
  ![Ace of heart](./Preview/Heart%20Ace.png)
  ![Two of heart](./Preview/Heart%202.png)
  ![Three of heart](./Preview/Heart%203.png)
  ![Four of heart](./Preview/Heart%204.png)
  ![Five of heart](./Preview/Heart%205.png)
  ![Jack of heart](./Preview/Heart%20Jack.png)
  ![Queen of heart](./Preview/Heart%20Queen.png)
  ![King of heart](./Preview/Heart%20King.png)

- Spade
  
  ![Ace of spade](./Preview/Spade%20Ace.png)
  ![Two of spade](./Preview/Spade%202.png)
  ![Three of spade](./Preview/Spade%203.png)
  ![Four of spade](./Preview/Spade%204.png)
  ![Five of spade](./Preview/Spade%205.png)
  ![Jack of spade](./Preview/Spade%20Jack.png)
  ![Queen of spade](./Preview/Spade%20Queen.png)
  ![King of spade](./Preview/Spade%20King.png)

In a game, each tile appears only once until the current deck is emptied. Allowing the player to know what may come next based one the received tiles.

When a deck of tile is empty, a new deck is shuffled and distributed to the player.

### Hands
Possible hands are based on Poker hands.

- Three or more of a kind. Any rank repeated at least 3 times.

  ![Two of club](./Preview/Club%202.png)
  ![Two of diamond](./Preview/Diamond%202.png)
  ![Two of heart](./Preview/Heart%202.png)

- Flush. At least 5 tiles from the same suit.

  ![Two of diamond](./Preview/Diamond%202.png)
  ![Three of diamond](./Preview/Diamond%203.png)
  ![Five of diamond](./Preview/Diamond%205.png)
  ![Jack of diamond](./Preview/Diamond%20Jack.png)
  ![Queen of diamond](./Preview/Diamond%20Queen.png)

- Suit. At least 5 tiles from any suit in order.

  ![Four of spade](./Preview/Spade%204.png)
  ![Five of club](./Preview/Club%205.png)
  ![Jack of heart](./Preview/Heart%20Jack.png)
  ![Queen of heart](./Preview/Heart%20Queen.png)
  ![King of diamond](./Preview/Diamond%20King.png)

- Straight flush. At least 5 tiles from the same suit in order.

  ![Ace of spade](./Preview/Spade%20Ace.png)
  ![Two of spade](./Preview/Spade%202.png)
  ![Three of spade](./Preview/Spade%203.png)
  ![Four of spade](./Preview/Spade%204.png)
  ![Five of spade](./Preview/Spade%205.png)
