//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract MyToken is ERC20Pausable, Ownable {

    constructor(uint256 initialSupply) ERC20("My Token", "MT") {
        _mint(msg.sender, initialSupply * 10 ** uint256(decimals()));
    }

    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    function grantMinterRole(address account) public onlyOwner {
        _setupRole(DEFAULT_ADMIN_ROLE, account);
        grantRole(MINTER_ROLE, account);
    }

    function revokeMinterRole(address account) public onlyOwner {
        revokeRole(MINTER_ROLE, account);
    }

    function pause() public onlyPauser {
        _pause();
    }

    function unpause() public onlyPauser {
        _unpauser();
    }
}