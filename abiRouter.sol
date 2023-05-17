// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ABIRouter is Ownable, Pausable, ReentrancyGuard {
    mapping(address => bool) public allowedContracts;

    event FunctionCallRouted(
        address indexed caller,
        address indexed target,
        bytes data,
        bytes result
    );

    function route(bytes calldata data, address target) external whenNotPaused nonReentrant returns (bytes memory) {
        require(allowedContracts[target], "Target contract not allowed");

        (bool success, bytes memory result) = target.delegatecall(data);
        require(success, "Delegatecall failed");

        // Moved the event after the external call.
        emit FunctionCallRouted(msg.sender, target, data, result);
        return result;
    }

    function addAllowedContract(address contractAddress) external onlyOwner {
        allowedContracts[contractAddress] = true;
    }

    function removeAllowedContract(address contractAddress) external onlyOwner {
        allowedContracts[contractAddress] = false;
    }

    function validateInput(bytes calldata data, address target) external view returns (bool) {
        require(allowedContracts[target], "Target contract not allowed");
        (bool success,) = target.staticcall(data);
        return success;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
