// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract MyToken is ERC20Pausable, Ownable {
    event TokensMinted(address indexed minter, address indexed to, uint256 amount);
    event TokensBurned(address indexed burner, address indexed minter);
    event MinterRoleGranted(address indexed owner, address indexed minter);
    event MinterRoleRevoked(address indexed owner, address indexed minter);
    event Paused(address account);
    event Unpaused(address account);

    constructor(uint256 initialSupply) ERC20("My Token", "MT") {
        _mint(msg.sender, initialSupply *10 ** uint256(decimals()));
    }

    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
        emit TokensMinted(msg.sender, to, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    function grantMinterRole(address account) public onlyOwner {
        _setupRole(DEFAULT_ADMIN_ROLE, account);
        grantRole(MINTER_ROLE, account);
        emit MinterRoleGranted(msg.sender, account);
    }

    function revokeMinterRole(address account) public onlyOwner {
        revokeRole(MINTER_ROLE, account);
        emit MinterRoleRevoked(msg.sender, account);
    }

    function pause() public onlyPauser {
        _pause();
        emit Paused(msg.sender);
    }

    function unpaused() public onlyPauser {
        _unpaused();
        emit Unpaused(msg.sender);
    }
}