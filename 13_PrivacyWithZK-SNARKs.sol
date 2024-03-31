//SPDX-License-Identifier: mIT

pragma solidity ^0.8.0;

import "https://github.com/HajimeK/BlockchainDevND/blob/master/lessons/Zokrates/zokrates/code/square/verifier.sol";

contract AgeVerification {

    ZoKratesVerifier public verifier;
    address public owner;

    event AgeVerified(address indexed user);

    constructor(address _verifier) {
        verifier = ZoKratesVerifier(_verifier);
        owner = msg.sender;
    }

    function requestAgeVerification(uint256 _birthdate, uint256[2] memory _proof) external {
        require(verifier.verifyTx(_proof, _birthdate), "Age verification failed");
        emit AgeVerified(msg.sender);
    }
}