# Tonmics Comic Pad - Digital Collectibles Marketplace

This contract implements a digital collectibles marketplace for Tonmics Comic Pad, featuring mega packages and exclusive packages with gems, keys, and TMS points.

## Features

-   **Mega Packages:** Purchase packages containing gems, keys, and TMS points.
-   **Exclusive Packages:** Purchase premium packages with exclusive gems.
-   **User Purchase Tracking:** Track user purchases and balances.
-   **Owner Management:** Enable/disable packages, update prices, and withdraw funds.
-   **Withdrawal System:** Allow the owner to withdraw contract funds.

## Contract Structure

### Imports

-   `@stdlib/deploy`: Basic contract deployment functionality.
-   `@stdlib/ownable`: Ownership pattern utilities.

### Message Definitions

-   **User Actions:**
    -   `BuyMegaPackage`: Purchase a mega package.
        ```
        {
          "packageId": 2, // Example: Purchase "Hero's Journey" (package ID 2)
          "amount": 573600000 // Example: Pay 0.5736 TON, represented as 573600000 nanoTON
        }
        ```
    -   `BuyExclusive`: Purchase an exclusive package.
        ```
        {
          "packageId": 1, // Example: Purchase "Cosmic Crossover" (package ID 1)
          "amount": 14350000000 // Example: Pay 14.350 TON, represented as 14350000000 nanoTON
        }
        ```
-   **Owner Administration:**
    -   `ToggleMegaPackage`: Enable/disable a mega package.
        ```
        {
          "packageId": 3 // Example: Toggle "Vigilante Vault" (package ID 3)
        }
        ```
    -   `ToggleExclusivePackage`: Enable/disable an exclusive package.
        ```
        {
          "packageId": 9 // Example: Toggle "Tonmics Legend" (package ID 9)
        }
        ```
    -   `Withdraw`: Withdraw funds from the contract.
        ```
        {
          "amount": 10000000000 // Example: Withdraw 10 TON, represented as 10000000000 nanoTON
        }
        ```
    -   `UpdateMegaPackage`: Update mega package details.
        ```
        {
          "packageId": 2, // Example: Update "Hero's Journey"
          "price": 600000000, // New price 0.6 TON
          "gems": 25, // New gem amount
          "keys": 25, // New key amount
          "tmsPoints": 5, // new tms points
        }
        ```
    -   `UpdateExclusivePackage`: Update exclusive package details.
        ```
        {
          "packageId": 1, // Example: Update "Cosmic Crossover"
          "price": 15000000000, // New price 15 TON
          "gems": 55 // New gem amount
        }
        ```
    -   `ToggleContractState`: pauses or unpauses contract.
        ```
        "ToggleContractState" // no payload
        ```

### Data Structures

-   `MegaPackage`: Stores mega package configurations (price, gems, keys, TMS points, isActive).
-   `ExclusivePackage`: Stores exclusive package configurations (price, gems, isActive).
-   `UserInfo`: Stores user progress (gems, keys, TMS points, purchased packages, last purchase time).
-   `Collectibles`: Stores global sales metrics.

### Contract State

-   `owner`: Contract owner address.
-   `contractAddress`: Contract's address.
-   `megaPackages`: Map of mega package configurations.
-   `exclusivePackages`: Map of exclusive package configurations.
-   `userBalances`: Map of user balances.
-   `paused`: Contract pause status.
-   `contractBalance`: Contract balance (in nanoTON).
-   `s_collectibles`: Global sales metrics.

### Initialization

The `init()` function initializes the contract state, sets up mega and exclusive packages, and sets the initial contract balance to 0. All TON values are stored and handled as nanoTON.

### Business Logic

-   **`receive(msg: BuyMegaPackage)`:**
    -   Validates the package ID and purchase amount (in nanoTON).
    -   Updates user balances with purchased items.
    -   Updates contract balance and global sales metrics.
-   **`receive(msg: BuyExclusive)`:**
    -   Validates the package ID and purchase amount (in nanoTON).
    -   Updates user balances with purchased items.
    -   Updates contract balance and global sales metrics.

### Admin Functions

-   **`receive(msg: Withdraw)`:**
    -   Allows the owner to withdraw funds (in nanoTON), ensuring a minimum storage balance.
-   **`receive(msg: UpdateMegaPackage)`:**
    -   Allows the owner to update mega package details (price in nanoTON).
-   **`receive(msg: UpdateExclusivePackage)`:**
    -   Allows the owner to update exclusive package details (price in nanoTON).
-   **`receive(msg: ToggleMegaPackage)`:**
    -   Allows the owner to toggle mega package activity.
-   **`receive(msg: ToggleExclusivePackage)`:**
    -   Allows the owner to toggle exclusive package activity.
-   **`receive("ToggleContractState")`:**
    -   Allows the owner to pause or unpause the contract.

### Getters

-   `getUserInfo(sender: Address)`: Returns user information.
    ```
    // Example usage (assuming sender is a valid address)
    getUserInfo(address("EQ..."))
    ```
-   `amountWithdrawableByOwner(sender: Address)`: Returns the amount withdrawable by the owner (in nanoTON).
-   `getUserMegaPackageGems(sender: Address)`: Returns user gems from mega packages.
-   `getUserExclusivePackageGems(sender: Address)`: Returns user gems from exclusive packages.
-   `isPaused()`: Returns the contract pause status.
-   `getMegaPackageInfo(packageId: Int)`: Returns mega package information.
    ```
    // Example usage
    getMegaPackageInfo(2) // Get info for "Hero's Journey"
    ```
-   `getExclusivePackageInfo(packageId: Int)`: Returns exclusive package information.
    ```
    // Example usage
    getExclusivePackageInfo(1) // Get info for "Cosmic Crossover"
    ```
-   `getTotalCollectiblesSold()`: Returns total collectibles sold.
-   `isContractPaused()`: Returns contract paused status.
-   `getContractBalance()`: Returns contract balance (in nanoTON).
-   `getContractAddress()`: Returns contract address.

### Incoming TON Transfer

-   `receive()`: Accepts incoming TON transfers and logs a message.

## Deployment and Usage via TON IDE (ide.ton.org)

1.  **Open TON IDE:** Navigate to [https://ide.ton.org/](https://ide.ton.org/) in your web browser.
2.  **Create a New Project:** Click "New Project" and select a suitable project name.
3.  **Paste the Contract Code:** Copy the entire contract code provided above and paste it into the main contract file within your new project in the TON IDE.
4.  **Compile the Contract:** Click the "Build" (hammer) icon in the TON IDE. This will compile your FunC contract. If there are any errors, address them based on the error messages.
5.  **Deploy the Contract:**
    -   Click the "Deploy" (rocket) icon.
    -   If this is your first time deploying, you'll need to connect your wallet. TON IDE supports various TON wallets.
    -   You'll be prompted to provide the initial storage value. Since this contract has an `init()` function with predefined values, you can generally proceed with the default storage values.
    -   Review the deployment details and confirm the transaction. You will need to pay for the deployment fees.
6.  **Interact with the Contract:**
    -   Once deployed, the TON IDE will show the contract's address.
    -   You can now send messages to the contract using the "Send Message" feature.
    -   To purchase packages, use the `BuyMegaPackage` or `BuyExclusive` messages, providing the correct `packageId` and `amount` (in nanoTON).
    -   For owner functions, ensure you are sending messages from the owner's address.
    -   Use the "Get Methods" section to call the getter functions and retrieve contract data.
7.  **Monitor Transactions:** Use a TON blockchain explorer (e.g., tonscan.io) to monitor the contract's transactions and state changes.

**Important Notes:**
-   Always test your contract thoroughly on the TON testnet before deploying to the mainnet.
- When deploying the smart contract, the `owner` address should be replaced with the deployer wallet address for testing purposes:

  ```tact
  owner: Address = address("UQBl-I1LPsZS0pzBirAHrsUACHoaY9zDDOZR7Bz42XmTPA7l");

-   Always test your contract thoroughly on the TON testnet before deploying to the mainnet.
