// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import { ERC721 } from "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Mons is Ownable, ERC721 {

    error MsgSenderIsNotOwner();

    uint256 public currentTokenId;
    string public baseURI;

    // Mons TokenID => Blocknumber Minted At
    mapping(uint256 => uint256) public monsBlockNumber;

    constructor(
        string memory name, 
        string memory symbol
    ) ERC721(name, symbol) {}

// Sets the block number the tokenID is minted at - for reward calculation
    function safeMint(address to) public {
        _safeMint(to, currentTokenId);
        monsBlockNumber[currentTokenId] = block.number;
        ++currentTokenId;
    }

// Mint the user some rewards tokens, based on the amount of time since last reward claim
// Because its tied to the tokenID, it adds value based on last reward claim
    function claimReward(address _to, uint256 _tokenId) external {
        if(_msgSender() != _to && !isApprovedForAll(_to, _msgSender())) revert MsgSenderIsNotOwner();
        uint256 reward = block.number - monsBlockNumber[_tokenId];
        monsBlockNumber[_tokenId] = block.number;

        //rewardsToken.mint(_msg.sender(), reward);
    }

    function checkRewardsAllocated(uint256 _tokenId) external view returns (uint256){
        return (block.number - monsBlockNumber[_tokenId]);
    }

    function setBaseURI(string memory uri) external onlyOwner {
        baseURI = uri;
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}