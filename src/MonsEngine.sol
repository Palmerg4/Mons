// SPDX-License-Identifier: MIT

import { IERC721 } from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

pragma solidity 0.8.19;

contract MonsEngine {

    IERC721 mons;

    error UserIsAlreadyInQue();
    error UserIsNotInQue();
    error MsgSenderIsNotUser();
    error PartySizeIncorrect();
    error MatchAlreadyFound();
    error QueTimeViolation();

    uint256[] public emptyArray;
    uint256 public queLockPeriod = 3;

/*
* 
    Another thought:
        - Pokemon type game
            - user can mint a mon and add it to their 'party'
            - party is 4 mons
            - mons are randomly selected at mint
            - mons have an attack and defense
            - mons can attack the opponent or defend the user
            - mons can level up after a win

        User interaction:
            - user selects their party and look for a match
            - user plays 1 mon per turn, or attacks/defends
            - user loses if all mons die, or user health pool hits 0
            - winners mons receive 'exp'. level is based on total exp, exponential level up. 92 is half of 99
    - 
*/

//
// Might just make a struct for the user, and have one mapping with all values assigned 
//

// Picks a random player in que to match against. Increments on player joining que, decrements by 2 when a match is found
    uint256 public playersInQue;

// Users Mons - players picks 4 mons from this mapping to be in the party
    mapping(address => Mon[]) public userMons;

// User assigned positionInQue based on playersInQue at the time of matchMaking - need to figure out how to get around this value being higher than playersInQue at any given time
    mapping(uint256 => address) public positionInQue;

// Map user to opponent after `findMatch()` is called
    mapping(address => address) public opponent;

// Map users que block, so that the random opponent value cannot be determined easily; I.E user will have to wait a few blocks after entering que to find an opponent
    mapping(address => uint256) public queTime;

// Set when user calls `matchMake()` with their desired mons indexes. Deleted after game ends - maybe not needed if it gets set on matchMake()
    mapping(address => uint256[]) public userParty;

// Set true after user calls `matchMake()` - set to false after match
    mapping(address => bool) public userInMatchMakeQue;

    struct Mon {
        uint256 tokenId;
        uint256 attack;
        uint256 defence;
        uint256 health;
        uint256 exp;
    }

    function enterQue(address _user, uint256[] memory _mons) external {
        uint256 length = _mons.length;
        
        if(_user != msg.sender) revert MsgSenderIsNotUser();
        userParty[msg.sender] = _mons;

        // User mons balance check - would use 721 for this most likely
        //
        //

        if(userInMatchMakeQue[msg.sender]) revert UserIsAlreadyInQue();
        if(length != 4) revert PartySizeIncorrect();
        
        opponent[msg.sender] = address(0);
        userInMatchMakeQue[msg.sender] = true;
        queTime[msg.sender] = block.number;
        ++playersInQue;
    }

    function leaveQue(address _user) external {

        if(_user != msg.sender) revert MsgSenderIsNotUser();
        userParty[msg.sender] = emptyArray;

        if(!userInMatchMakeQue[msg.sender]) revert UserIsNotInQue();
        if(opponent[msg.sender] != address(0)) revert MatchAlreadyFound();
        
        userInMatchMakeQue[msg.sender] = false;
        --playersInQue;
    }

    function findMatch(address _user) external {
        if(_user != msg.sender) revert MsgSenderIsNotUser();
        if(!userInMatchMakeQue[msg.sender]) revert UserIsNotInQue();
        if(queTime[msg.sender] > block.number + queLockPeriod) revert QueTimeViolation();

        uint256 opponentIndex = uint256(keccak256(abi.encodePacked(blockhash(queTime[msg.sender])))) % playersInQue;

        opponent[msg.sender] = positionInQue[opponentIndex];
    }

// Need user interaction with mons
//      - Mint mons
//      - Create party with their mons and join mathcmaking que ✅
//      - Battle opponent

}
