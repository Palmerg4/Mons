// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { ERC20 } from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract ERC20Mock is ERC20, Ownable {

    error CallerNotMonsContract();

    address public monsContract;

    modifier onlyMonsContract(){
        if(msg.sender != monsContract) revert CallerNotMonsContract();
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address initialAccount,
        uint256 initialBalance
    ) payable ERC20(name, symbol) {
        _mint(initialAccount, initialBalance);
    }

    function setMonsContract(address _monsConract) public onlyOwner{
        monsContract = _monsConract;
    }

    function mint(address account, uint256 amount) public onlyMonsContract {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
}
