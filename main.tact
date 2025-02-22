/*
    TONMICS COMIC PAD - DIGITAL COLLECTIBLES MARKETPLACE
    Features:
    - Mega packages with gems/keys/TMS points
    - Exclusive packages with premium gems
    - Purchase tracking per user
    - Owner management of packages
    - Withdrawal system
*/

/* ---------------------------- IMPORTS --------------------------- */
import "@stdlib/deploy";  // Basic contract deployment functionality
import "@stdlib/ownable"; // Ownership pattern utilities

/* ---------------------- MESSAGE DEFINITIONS --------------------- */
// All user-initiated actions
message BuyMegaPackage {
    packageId: Int;       // ID of mega package (1-4)
    amount: Int as coins; // Payment amount in TON coins
}

message BuyExclusive {
    packageId: Int;       // ID of exclusive package (1-9)
    amount: Int as coins; // Payment amount
}

// Owner administration messages
message ToggleMegaPackage {
    packageId: Int;       // Which mega package to enable/disable
}

message ToggleExclusivePackage {
    packageId: Int;       // Which exclusive package to toggle
}

message Withdraw {
    amount: Int as coins; // TON amount to withdraw from contract
}

message UpdateMegaPackage {
    packageId: Int;      // ID of package to update
    price: Int as coins; // New price in TON
    gems: Int;           // New gem quantity
    keys: Int;           // New key quantity
    tmsPoints: Int;      // New TMS points value
}

message UpdateExclusivePackage {
    packageId: Int;      // ID to update
    price: Int as coins; // New price
    gems: Int;           // New gem amount
}

/* ----------------------- DATA STRUCTURES ------------------------ */
// Package configuration templates
struct MegaPackage {
    price: Int as coins; // Cost in TON
    gems: Int;           // Included gems
    keys: Int;           // Included keys
    tmsPoints: Int;      // TMS loyalty points
    isActive: Bool;      // Available for purchase?
}

struct ExclusivePackage {
    price: Int as coins; // TON cost
    gems: Int;           // Premium gems
    isActive: Bool;      // Purchaseable status
}

// User progress tracking
struct UserInfo {
    gems: Int as int64;            // Total gems accumulated
    keys: Int as int64;            // Total keys collected
    tmsPoints: Int as int64;       // Loyalty points earned
    megaPackageGems: Int as int64; // Gems from mega packages only
    exclusivePackageGems: Int as int64; // Gems from exclusives
    purchasedMegaPackages: map<Int, Bool>;     // Owned mega packages
    purchasedExclusivePackages: map<Int, Bool>; // Owned exclusives
    lastPurchaseTime: Int as int64; // Timestamp of last buy
}

// Global sales tracking
struct Collectibles {
    gems: Int;      // Total gems sold
    keys: Int;      // Total keys distributed
    tmsPoints: Int; // Total TMS points awarded
}

/* --------------------- MAIN CONTRACT CODE ---------------------- */
contract TonmicsComicPad with Deployable, Ownable {
    
    // ================== SYSTEM CONSTANTS ====================
    const MIN_TON_FOR_STORAGE: Int = ton("0.01"); // Minimum reserve balance
    const MAX_MEGA_PACKAGE_ID: Int = 4;     // Total mega packages available
    const MAX_EXCLUSIVE_PACKAGE_ID: Int = 9; // Total exclusive packages
    
    // ================= CONTRACT STATE ========================
    owner: Address = address("UQBl-I1LPsZS0pzBirAHrsUACHoaY9zDDOZR7Bz42XmTPA7l"); // Fixed owner
    contractAddress: Address;              // Self-address reference
    megaPackages: map<Int, MegaPackage>;   // Mega package configurations
    exclusivePackages: map<Int, ExclusivePackage>; // Exclusive configs
    
    userBalances: map<Address, UserInfo>;  // User account states
    paused: Bool;                          // Emergency stop flag
    contractBalance: Int as coins;         // Total held funds
    
    // Global sales metrics
    s_collectibles: Collectibles = Collectibles{
        gems: 0,
        keys: 0,
        tmsPoints: 0
    };

    /* -------------------- INITIALIZATION -------------------- */

    init() {

        self.contractBalance = 0;
        self.paused = false;
        self.contractAddress=myAddress();
     // Initialize Mega Packages (Rising Panel, Hero's Journey, etc.)
        // Rising Panel
        self.megaPackages.set(1, MegaPackage{
            price: ton("0.1434"),
            gems: 0,
            keys: 10,
            tmsPoints: 400,
            isActive: true
        });

        // Hero's Journey
        self.megaPackages.set(2, MegaPackage{
            price: ton("0.5736"),
            gems: 20,
            keys: 20,
            tmsPoints: 0,
            isActive: true
        });

        // Vigilante Vault
        self.megaPackages.set(3, MegaPackage{
            price: ton("0.8604"),
            gems: 10,
            keys: 35,
            tmsPoints: 100,
            isActive: true
        });

        // Legends League
        self.megaPackages.set(4, MegaPackage{
            price: ton("2.2944"),
            gems: 50,
            keys: 35,
            tmsPoints: 3500,
            isActive: true
        });
        
    // Initialize Exclusive Packages (Cosmic Crossover, Infinity Saga, etc.)
        // Cosmic Crossover
        self.exclusivePackages.set(1, ExclusivePackage{
            price: ton("14.350"),
            gems: 50,
            isActive: true
        });

        // Infinity Saga
        self.exclusivePackages.set(2, ExclusivePackage{
            price: ton("2.870"),
            gems: 100,
            isActive: true
        });

        // Omniverse Mastery
        self.exclusivePackages.set(3, ExclusivePackage{
            price: ton("4.305"),
            gems: 150,
            isActive: true
        });

        // Secret Saga
        self.exclusivePackages.set(4, ExclusivePackage{
            price: ton("8.610"),
            gems: 300,
            isActive: true
        });

        // Infinity Warfront
        self.exclusivePackages.set(5, ExclusivePackage{
            price: ton("14.350"),
            gems: 500,
            isActive: true
        });

        // Quantum Rebirth
        self.exclusivePackages.set(6, ExclusivePackage{
            price: ton("28.700"),
            gems: 1000,
            isActive: true
        });

        // Absolute Zero Hour
        self.exclusivePackages.set(7, ExclusivePackage{
            price: ton("57.400"),
            gems: 2000,
            isActive: true
        });

        // The Endgame
        self.exclusivePackages.set(8, ExclusivePackage{
            price: ton("143.500"),
            gems: 5000,
            isActive: true
        });

        // Tonmics Legend
        self.exclusivePackages.set(9, ExclusivePackage{
            price: ton("287.000"),
            gems: 10000,
            isActive: true
        });
    }
/* ------------------- BUSINESS LOGIC --------------------- */
    // Handle mega package purchases
    receive(msg: BuyMegaPackage) {
    require(!self.paused, "Contract is paused");
    require(msg.packageId >= 1 && msg.packageId <= self.MAX_MEGA_PACKAGE_ID, "Invalid mega package ID");

    let megaPackage: MegaPackage = self.megaPackages.get(msg.packageId)!!;
    require(megaPackage.isActive, "Mega package is not active");
    require(msg.amount == megaPackage.price, "Insufficient funds");
   
    if (self.userBalances.exists(sender())) {
        let previousUserBalance: UserInfo = self.userBalances.get(sender())!!;
        
        // Create a new map for purchased mega packages
        let updatedPurchasedMegaPackages = previousUserBalance.purchasedMegaPackages;

        // Set the new package ID in the purchasedMegaPackages map
        updatedPurchasedMegaPackages.set(msg.packageId, true);
     
        self.userBalances.set(sender(), UserInfo{
            gems: previousUserBalance.gems + megaPackage.gems,
            keys: previousUserBalance.keys + megaPackage.keys,
            tmsPoints: previousUserBalance.tmsPoints + megaPackage.tmsPoints,
            megaPackageGems: previousUserBalance.megaPackageGems + megaPackage.gems, // Track gems from mega packages
            exclusivePackageGems: previousUserBalance.exclusivePackageGems, // Preserve existing exclusive package gems
            purchasedMegaPackages: updatedPurchasedMegaPackages,
            purchasedExclusivePackages: previousUserBalance.purchasedExclusivePackages,
            lastPurchaseTime: now()
        });
    } else {
        // Create a new UserInfo for the user
        let newPurchasedMegaPackages: map<Int, Bool> = emptyMap();
        let newPurchasedExclusivePackages: map<Int, Bool> = emptyMap();
        newPurchasedMegaPackages.set(msg.packageId, true);
        
        self.userBalances.set(sender(), UserInfo{
            gems: megaPackage.gems,
            keys: megaPackage.keys,
            tmsPoints: megaPackage.tmsPoints,
            megaPackageGems: megaPackage.gems, // Track gems from mega packages
            exclusivePackageGems: 0, // Initialize exclusive package gems to 0 for new users
            purchasedMegaPackages: newPurchasedMegaPackages,
            purchasedExclusivePackages: newPurchasedExclusivePackages,
            lastPurchaseTime: now()
        });
    }

    self.contractBalance += msg.amount;
    self.s_collectibles.gems += megaPackage.gems;
    self.s_collectibles.tmsPoints += megaPackage.tmsPoints;
    self.s_collectibles.keys += megaPackage.keys;
}
// Handle Exclusive package purchases

   receive(msg: BuyExclusive) {
    require(!self.paused, "Contract is paused");
    require(msg.packageId >= 1 && msg.packageId <= self.MAX_EXCLUSIVE_PACKAGE_ID, "Invalid exclusive package ID");

    let exclusivePackage: ExclusivePackage = self.exclusivePackages.get(msg.packageId)!!;
    require(exclusivePackage.isActive, "Exclusive package is not active");
    require(msg.amount == exclusivePackage.price, "Insufficient funds");
    
    if (self.userBalances.exists(sender())) {
        let userInfo: UserInfo = self.userBalances.get(sender())!!;
        
        // Create updated maps
        let updatedPurchasedExclusivePackages = userInfo.purchasedExclusivePackages;
        updatedPurchasedExclusivePackages.set(msg.packageId, true);
        
        // Update user balance with exclusive package gems tracking
        self.userBalances.set(sender(), UserInfo{
            gems: userInfo.gems + exclusivePackage.gems,
            keys: userInfo.keys,
            tmsPoints: userInfo.tmsPoints,
            megaPackageGems: userInfo.megaPackageGems,
            exclusivePackageGems: userInfo.exclusivePackageGems + exclusivePackage.gems, // Track exclusive package gems
            purchasedMegaPackages: userInfo.purchasedMegaPackages,
            purchasedExclusivePackages: updatedPurchasedExclusivePackages,
            lastPurchaseTime: now()
        });
    } else {
        // Create a new UserInfo for the user
        let newPurchasedMegaPackages: map<Int, Bool> = emptyMap();
        let newPurchasedExclusivePackages: map<Int, Bool> = emptyMap();
        newPurchasedExclusivePackages.set(msg.packageId, true);
        
        self.userBalances.set(sender(), UserInfo{
            gems: exclusivePackage.gems,
            keys: 0,
            tmsPoints: 0,
            megaPackageGems: 0,
            exclusivePackageGems: exclusivePackage.gems, // Set initial exclusive package gems
            purchasedMegaPackages: newPurchasedMegaPackages,
            purchasedExclusivePackages: newPurchasedExclusivePackages,
            lastPurchaseTime: now()
        });
    }
    
    self.contractBalance += msg.amount;
    self.s_collectibles.gems += exclusivePackage.gems;
}

    

 /* ------------------- ADMIN FUNCTIONS -------------------- */
    receive(msg: Withdraw) {
        require(sender() == self.owner, "Only owner can withdraw");
        require(msg.amount <= self.contractBalance - self.MIN_TON_FOR_STORAGE, "Insufficient contract balance after accounting for storage");

        send(SendParameters{
            to: self.owner,
            value: msg.amount,
            mode: SendRemainingValue + SendIgnoreErrors
        });

        self.contractBalance -= msg.amount;
    }

    receive(msg: UpdateMegaPackage) {
        require(sender() == self.owner, "Only owner can update mega packages");
        require(msg.packageId >= 1 && msg.packageId <= self.MAX_MEGA_PACKAGE_ID, "Invalid mega package ID");
        
        self.megaPackages.set(msg.packageId, MegaPackage{
            price: msg.price,
            gems: msg.gems,
            keys: msg.keys,
            tmsPoints: msg.tmsPoints,
            isActive: true
        });
    }

    receive(msg: UpdateExclusivePackage) {
        require(sender() == self.owner, "Only owner can update exclusive packages");
        require(msg.packageId >= 1 && msg.packageId <= self.MAX_EXCLUSIVE_PACKAGE_ID, "Invalid exclusive package ID");
        
        self.exclusivePackages.set(msg.packageId, ExclusivePackage{
            price: msg.price,
            gems: msg.gems,
            isActive: true
        });
    }

    receive(msg: ToggleMegaPackage) {
        require(sender() == self.owner, "Only owner can toggle mega packages");
        require(msg.packageId >= 1 && msg.packageId <= self.MAX_MEGA_PACKAGE_ID, "Invalid mega package ID");
        
        let megaPackage: MegaPackage = self.megaPackages.get(msg.packageId)!!;
        megaPackage.isActive = !megaPackage.isActive;
        self.megaPackages.set(msg.packageId, megaPackage);
    }
    
    receive(msg: ToggleExclusivePackage) {
        require(sender() == self.owner, "Only owner can toggle exclusive packages");
        require(msg.packageId >= 1 && msg.packageId <= self.MAX_EXCLUSIVE_PACKAGE_ID, "Invalid exclusive package ID");
        
        let exclusivePackage: ExclusivePackage = self.exclusivePackages.get(msg.packageId)!!;
        exclusivePackage.isActive = !exclusivePackage.isActive;
        self.exclusivePackages.set(msg.packageId, exclusivePackage);
    }
    receive("ToggleContractState") {
    require(sender() == self.owner, "Only owner can toggle contract state");

    self.paused = !self.paused;
}

/* --------------------- ACCEPT INCOMING TON TRANSFER -------------------------- */
  receive() {
           dump("funds received");   
    }

    
/* --------------------- GETTERS -------------------------- */
    get fun getUserInfo(sender: Address): UserInfo? {
        return self.userBalances.get(sender);
    }

    get fun amountWithdrawableByOwner (sender: Address): Int{
        let _amount: Int= self.contractBalance - self.MIN_TON_FOR_STORAGE;
        return _amount;

    }
   
    get fun getUserMegaPackageGems(sender: Address): Int {
        
        if (self.userBalances.exists(sender)) {
            
            return self.userBalances.get(sender)!!.megaPackageGems;
        }
        return 0;
    }

    get fun getUserExclusivePackageGems(sender: Address): Int {
    if (self.userBalances.exists(sender)) {
        return self.userBalances.get(sender)!!.exclusivePackageGems;
    }
    return 0;
}
     
    get fun isPaused(): Bool {
        return self.paused;
    }
  
    get fun getMegaPackageInfo(packageId: Int): MegaPackage? {
        return self.megaPackages.get(packageId);
    }
    
    get fun getExclusivePackageInfo(packageId: Int): ExclusivePackage? {
        return self.exclusivePackages.get(packageId);
    }

    get fun getTotalCollectiblesSold(): Collectibles {
        return self.s_collectibles;
    }

    get fun isContractPaused(): Bool {
        return self.paused;
    }

    get fun getContractBalance(): Int {
        return self.contractBalance;
    }

   
     get fun getContractAddress (): Address{
        return self.contractAddress;
     }

}