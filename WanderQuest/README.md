# WanderQuest

WanderQuest is a simple blockchain-based game where players navigate through a virtual world, encountering various challenges and opportunities along the way. The game is built on the Ethereum blockchain using Solidity smart contracts.

## Features

- **Exploration:** Explore a vast virtual world filled with mobs, shops, mines, and portals.
- **Action-packed Gameplay:** Engage in actions such as moving, fighting mobs, mining for gold, buying food, and entering portals.
- **Resource Management:** Manage your experience points (XP), gold, and food to survive and thrive in the game world.
- **Dynamic Environment:** Encounter mobs to fight, shops to buy food, mines to mine for gold, and portals to progress in the game.
- **Winning Condition:** Be the first player to discover and enter the portal to win the game.

## Getting Started

To get started with WanderQuest, follow these steps:

1. **Install MetaMask:** Install the MetaMask extension in your web browser and set up an Ethereum account.
2. **Deploy Smart Contract:** Deploy the WanderQuest smart contract on the Ethereum blockchain.
3. **Connect MetaMask:** Connect your MetaMask wallet to the WanderQuest game interface.
4. **Start Playing:** Start playing WanderQuest by interacting with the game interface using MetaMask.

## Functions and Actions

- **action(uint a):** This function allows the player to perform various actions in the game. Each action is represented by a unique integer value 'a':
    - 1: Go in/out - Move in or out of a location.
    - 2: Go UP - Move up in the game world.
    - 3: Go DOWN - Move down in the game world.
    - 4: Go RIGHT - Move right in the game world.
    - 5: Go LEFT - Move left in the game world.
    - 6: Eat - Consume food to replenish energy.
    - 7: Buy Food - Purchase food from nearby shops.
    - 8: Enter Portal - Enter the portal to progress in the game.
    - 9: Mine - Mine for gold in nearby mines.

## Contributing

Contributions to WanderQuest are welcome! If you have any ideas for improvements or new features, feel free to open an issue or submit a pull request.

## License

WanderQuest is licensed under the [MIT License](LICENSE).
