// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title VaultManager
 * @notice A simple contract that manages user vaults for storing ETH.
 *         Includes a deposit function (to add funds to a vault) and a
 *         vulnerable withdraw function that demonstrates an inline
 *         assembly bug with a narrow type (bool).
 */
contract VaultManager {
    struct Vault {
        address owner;
        uint256 balance;
    }

    address public admin;
    Vault[12] public vaults;  // Fixed-size array (index 0..511)
    // In a more sophisticated system, you'd likely use a mapping and more checks.

    constructor() payable {
        // Deployer is the admin
        admin = msg.sender;
    }

    /**
     * @dev Deposit Ether into a vault specified by vaultId (0..511).
     *      The vault must already be claimed/owned by the sender or must be empty
     *      so a new sender can claim it. This is just an example.
     */
    function deposit(uint8 vaultId) external payable {
        // You could do more robust checks (is vaultId in range, etc.)
        require(vaultId < 12, "Invalid vault ID");

        // If vault is empty, claim ownership, otherwise require the same owner
        if (vaults[vaultId].owner == address(0)) {
            vaults[vaultId].owner = msg.sender;
        } else {
            require(vaults[vaultId].owner == msg.sender, "Not vault owner");
        }

        vaults[vaultId].balance += msg.value;
    }

    /**
     * @notice Withdraws funds from a vault. Normal users can withdraw their own vault,
     *         and the admin can override to withdraw any vault.
     * @param req Packed request containing vaultId (uint8) and override flag (bool).
     *
     * Vulnerability: The function uses inline assembly to parse `vaultId` and `override`
     * flag from `req`, allowing “dirty” bits to bypass security checks if the boolean
     * is not strictly 0 or 1.
     */
    function withdrawPacked(bytes32 req) external {
        uint256 amount;
        assembly {
            // Load the 32-byte request from calldata (after the 4-byte function selector)
            let data := calldataload(4)

            // Parse vaultId (uint8) from the lowest 8 bits of `data`
            let vid := and(data, 0xFF)

            // Compute vault.owner slot => each Vault is 2 storage slots (owner, balance).
            //  - admin is slot 0
            //  - vaults start at slot 1
            // vaults[vaultId].owner => storage slot = 1 + 2 * vaultId
            let ownerSlot := add(1, mul(vid, 2))

            // Parse override flag (bool) from second-lowest byte
            let flagByte := byte(30, data)

            // If override==1 => require msg.sender == admin
            if eq(flagByte, 1) {
                if iszero(eq(sload(0), caller())) { revert(0, 0) }
            }

            // If override==0 => require msg.sender == vault owner
            if eq(flagByte, 0) {
                if iszero(eq(sload(ownerSlot), caller())) { revert(0, 0) }
            }

            // If override is any other non-zero => no check => vulnerability

            // Load vault balance => vaults[vaultId].balance is at ownerSlot+1
            let balSlot := add(ownerSlot, 1)
            amount := sload(balSlot)
            // Zero out the balance
            sstore(balSlot, 0)
        }

        require(amount > 0, "No funds");
        payable(msg.sender).transfer(amount);
    }
}