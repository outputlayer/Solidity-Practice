// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.25 < 0.9.0;


contract THEGUY {

    struct Player {
        address user;
        Position position;
        string doing;
        uint xp;
        uint gold;
        uint food;
        bool alive;
        bool winner;
    }

    struct Mob {
        string name;
        Position position;
        uint xp;
        uint gold;
        bool alive;
    }

    struct Shop{
        string name;
        Position position;
    }

    struct Mine{
        string name;
        Position position;
        uint gold;
    }

    struct Portal{
        string name;
        Position position;
    }

    struct Position {
        int x;
        int y;
    }

 

    mapping(uint => string) public act;
    mapping(uint => Mob) public mobs; 
    mapping(uint => Shop) public shops; 
    mapping(uint => Mine) public mines; 
    mapping(uint => Position) locations;

    Portal portal; 
    Player public player;
    uint private nonce = 0;
    uint public started;
    uint public num;

    constructor() {
    player = Player(msg.sender, Position(0, 0), "Nothing", 100, 0, 0, true, false);
    
    act[0] = "Nothing";
    act[1] = "Getting in/out";
    act[2] = "UP";
    act[3] = "DOWN";
    act[4] = "RIGHT";
    act[5] = "LEFT";
    act[6] = "Eating";
    act[7] = "Buying Food";
    act[8] = "Winning Game";

    for (uint i = 0; i < 10; i++) {
        mobs[i] = Mob("Billy", generateRandomPosition(), 5, 10, true);
    }

    shops[0] = Shop("SHOP", Position(4, 4)); 
    shops[1] = Shop("SHOP", Position(-4, -4)); 
    locations[0] = Position(4, 4);
    locations[1] = Position(-4, -4);

    for (uint j = 0; j < 4; j++) {
        mines[j] = Mine("MINE", generateRandomPosition(), 50);
    }

    portal = Portal("PORTAL", generateRandomPosition());
}

    function action(uint a) public  {
        require(player.alive, "Player must be alive to move.");
        require(player.winner == false, "You won this game!");

        if (a == 1){
        require(keccak256(bytes(player.doing)) == keccak256(bytes("Found mine!")) || keccak256(bytes(player.doing)) == keccak256(bytes("minning")), "Player must near to mine.");
        require(player.xp >= 46, "Get some food!");
        mining();
        }
        if (a == 2){
            require(keccak256(bytes(player.doing)) != keccak256(bytes("minning")), "Player must get out from mine.");
            player.position.y += 1;
            player.doing = "Walking";
            checkPosition(player.position.x, player.position.y);
            num = 2;
        }
        if (a == 3){
            require(keccak256(bytes(player.doing)) != keccak256(bytes("minning")), "Player must get out from mine.");
            player.position.y -= 1;
            player.doing = "Walking";
            checkPosition(player.position.x, player.position.y);
            num = 2;
        }
        if (a == 4){
            require(keccak256(bytes(player.doing)) != keccak256(bytes("minning")), "Player must get out from mine.");
            player.position.x += 1;
            player.doing = "Walking";
            checkPosition(player.position.x, player.position.y);
            num = 2;
        }
        if (a == 5){
            require(keccak256(bytes(player.doing)) != keccak256(bytes("minning")), "Player must get out from mine.");
            player.position.x -= 1;
            player.doing = "Walking";
            checkPosition(player.position.x, player.position.y);
            num = 2;
        }
        if (a == 6){    
            require(player.food > 0, "Player must have food.");
            player.food -= 1;
            player.xp = 100;
            player.doing = act[6];
        }
        if (a == 7){
            require(keccak256(bytes(player.doing)) == keccak256(bytes("Staying near to The SHOP!")), "Player must near to shop.");
            require(player.gold >= 10, "Not enough coins!");
            player.food += 1;
            player.gold -=10;
        }
        if (a == 8){
            require(keccak256(bytes(player.doing)) == keccak256(bytes("Staying near to The PORTAL!!!")), "You not found Portal yet");
            player.winner = true;
            player.doing = "Player won this fucking game!";
        } 
        if (a > 8){
            revert("Unxpected Action Please check act! " );
        }
        
        }


    function checkPosition(int x, int y) private {
        for (uint i = 0; i < 10; i++) {
            if (mobs[i].position.x == x && mobs[i].position.y == y){
                if (mobs[i].alive == true) {
                     player.doing = "Fighting";
                     player.xp -= 5;
                     player.gold += 10;
                     mobs[i].alive = false;
                }
                 
            }
        }
        for (uint i = 0; i < 4; i++) {
            if (mines[i].position.x == x && mines[i].position.y == y) {
                if (mines[i].gold > 0) {
                    player.doing = "Found mine!";
                    num = i;
                }
            }
        }

        if (portal.position.x == x && portal.position.y == y){
            player.doing = "Staying near to The PORTAL!!!";
        }

        for (uint i = 0; i < 2; i++) {
            if (shops[i].position.x == x && shops[i].position.y == y) {
                 player.doing = "Staying near to The SHOP!";
                       
        }


    }

    }


function mining() private {
    if (keccak256(bytes(player.doing)) == keccak256(bytes("Found mine!"))) {
       uint started = block.timestamp;
    }
    if (keccak256(bytes(player.doing)) == keccak256(bytes("mining"))) {
        uint256 elapsedTime = block.timestamp - started;
        uint256 miningTime = 150; 

        if (elapsedTime >= miningTime) {
            player.gold += 50;
            player.xp -= 45;
            mines[num].gold = 0;
        } else {
            player.gold += 50 * elapsedTime / miningTime;
            player.xp -= 50 * elapsedTime / miningTime;
            mines[num].gold -= 50 * elapsedTime / miningTime;
        }
    }
    player.doing = "minning";
}




function generateRandomPosition() private returns (Position memory) {
    bytes32 hash = keccak256(abi.encodePacked(nonce));
    uint randomNumber = uint(hash) % 8; // Get a random number between 0 and 7
    nonce++;
    uint randomX = randomNumber > 3 ? randomNumber - 3 : 3 - randomNumber; // Adjust to be within the range of -3 to 3
    bool isNegativeX = randomNumber % 2 != 0; // Track if X should be negative
    hash = keccak256(abi.encodePacked(nonce));
    randomNumber = uint(hash) % 8; // Get a new random number between 0 and 7
    nonce++;
    uint randomY = randomNumber > 3 ? randomNumber - 3 : 3 - randomNumber; // Adjust to be within the range of -3 to 3
    bool isNegativeY = randomNumber % 2 != 0; // Track if Y should be negative
    
    // Adjust to avoid (4,4) or (-4,-4)
    if (randomX == 3 && randomY == 3) {
        randomX = 2;
        randomY = 2;
    }

    Position memory newPos = Position(isNegativeX ? -int(randomX) : int(randomX), isNegativeY ? -int(randomY) : int(randomY));

    // Check if the new position is already occupied
    while(isPositionOccupied(newPos)) {
        // If occupied, generate new random positions
        hash = keccak256(abi.encodePacked(nonce));
        randomNumber = uint(hash) % 8;
        nonce++;
        randomX = randomNumber > 3 ? randomNumber - 3 : 3 - randomNumber;
        isNegativeX = randomNumber % 2 != 0;
        hash = keccak256(abi.encodePacked(nonce));
        randomNumber = uint(hash) % 8;
        nonce++;
        randomY = randomNumber > 3 ? randomNumber - 3 : 3 - randomNumber;
        isNegativeY = randomNumber % 2 != 0;

        // Adjust to avoid (4,4) or (-4,-4)
        if (randomX == 3 && randomY == 3) {
            randomX = 2;
            randomY = 2;
        }

        newPos = Position(isNegativeX ? -int(randomX) : int(randomX), isNegativeY ? -int(randomY) : int(randomY));
    }

    // Add the new position to the locations mapping
    uint index = nonce - 2; // Assuming nonce was incremented twice for generating randomX and randomY
    locations[index] = newPos;

    return newPos;
}

function isPositionOccupied(Position memory pos) private view returns (bool) {
    for (uint i = 0; i < nonce - 1; i++) {
        if (locations[i].x == pos.x && locations[i].y == pos.y) {
            return true;
        }
    }
    return false;
}

    
}
