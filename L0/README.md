# Golden Rain - ERC20 Token Shower

This smart contract, named "Golden Rain," facilitates sending ERC20 transactions (custom token) through L0 in a single transaction to the Optimism and Base networks randomly. The contract is designed to distribute ERC20 tokens in a playful manner, and it's deployed on Arbitrum.

### Contract Details:

- **Smart Contract Address**: [0xffa891f1b624269f832893665545569c6c9bed06](https://arbiscan.io/address/0xffa891f1b624269f832893665545569c6c9bed06#writeContract)
- **Programming Language**: Solidity
- **Compiler Version**: 0.8.22

### Features:

- `piss(uint n, address addy)`: Sends a specified number of ERC20 transactions in a single transaction. The transactions are sent to the Optimism and Base networks randomly. 
- `getTotalFee(uint n, address addy)`: Calculates the total fee for sending a specified number of transactions.
- `receive()`: Fallback function to receive Ether.
- `TokenContract`: Interface defining functions for interacting with ERC20 tokens.
- `SendParam` and `MessagingFee`: Structs defining parameters for sending transactions and messaging fees.

### How it Works:

1. The `piss` function sends ERC20 transactions. It calculates the fee for each transaction using the `getFee` function and sends the transaction with the calculated fee.
2. The `getFee` function calculates the fee for a single transaction based on the destination network (Optimism or Base).
3. The `getTotalFee` function calculates the total fee for sending a specified number of transactions.

### Example Transaction:

An example transaction for sending 100 transactions can be found [here](https://layerzeroscan.com/tx/0x867b61d852f6200ae865f33ff7316394ae4656b84890725b8248308d42f1967c).

### License:

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

