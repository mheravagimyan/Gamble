// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "hardhat/console.sol";
import "./GameToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoinFlip is Ownable {
    enum Status {
        PENDING, // 0
        WIN, // 1
        LOSE // 2
    }

    struct Game {
        address player;
        uint256 depositAmount;
        uint256 choice;
        uint256 result;
        uint256 prize;
        Status status;
    }

    uint256 public totalGamesCount; // = 0
    uint256 public minDepositAmount;
    uint256 public maxDepositAmount;
    uint256 public profit;
    uint256 public coeff;
    GameToken public token;

    mapping(uint256 => Game) public games;

    event GameFineshed(
        address indexed player, 
        uint256 depAmount, 
        uint256 chocie,
        uint256 result,
        uint256 prize,
        Status indexed status
    );

    constructor() {
        // token = GameToken(_token);
        // address(token);
        // address(this);
        coeff = 195;
        minDepositAmount = 100;
        maxDepositAmount = 1 ether;
        token = new GameToken();
    }

    function changeCoeff(uint256 _coeff) external onlyOwner {
        require(_coeff > 100, "CoinFlip: wrong coeff");
        coeff = _coeff;
    }

    function changeMaxMinBet(
        uint256 _minDepositAmount,
        uint256 _maxDepositAmount
    ) external onlyOwner {
        require(_minDepositAmount < _maxDepositAmount, "CoinFlip: Wrong dep amount!");
        maxDepositAmount = _maxDepositAmount;
        minDepositAmount = _minDepositAmount;
    }

    // struct Game {
    //     address player;
    //     uint256 depositAmount;
    //     uint256 choice;
    //     uint256 result;
    //     Status status;
    // }

    function play(
        uint256 depAmount,
        uint256 choice
    ) external {
        require(choice == 0 || choice == 1, "Not correct choice");
        require(depAmount >= minDepositAmount && depAmount <= maxDepositAmount, "Deposit amount in out of range");
        require(token.balanceOf(msg.sender) >= depAmount, "Not enough funds");
        require(token.allowance(msg.sender, address(this)) >= depAmount, "Not enough allowance");
        token.transferFrom(msg.sender, address(this), depAmount);
        require(token.balanceOf(address(this)) > depAmount * coeff / 100, "Contract not enough balance");
        Game memory game = Game(
            msg.sender,
            depAmount,
            choice,
            0,
            0, 
            Status.PENDING
        );
        uint256 result = block.number % 2; // 0 || 1
        if(result == choice) {
            game.result = result;
            game.status = Status.WIN;
            game.prize = depAmount * coeff / 100;
            // depAmount * 1e18 * coeff / 100 / 1e18;
            token.transfer(msg.sender, game.prize);
            games[totalGamesCount] = game;
        } else {
            game.result = result;
            game.status = Status.LOSE;
            game.prize = 0;
            profit += game.depositAmount;
            games[totalGamesCount] = game;
        }
        totalGamesCount += 1;

        emit GameFineshed(
            game.player,
            game.depositAmount,
            game.choice,
            game.result,
            game.prize,
            game.status
        );
    }


    function withdraw(uint256 _amount) external onlyOwner {
        require(token.balanceOf(address(this)) >= _amount, "Not enough funds");
        token.transfer(msg.sender, _amount);
    }

    function mint(uint256 _amount) public {
        token.mint(msg.sender, _amount);
    }

    function burn(uint256 _amount) public {
        token.burn(msg.sender, _amount);
    }   
}


// |.........|.........|
//  byte32 || 256 bit
//  uint8;
//  uint256; 

// contract A {
//     uint8 a;
//     uint64 c;
//     uint128 e;
//     uint256 b;
// }

// contract B {
//     bool a;
// }