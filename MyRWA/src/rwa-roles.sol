// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Allowlist} from "@openzeppelin/community-contracts/contracts/token/ERC20/extensions/ERC20Allowlist.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Custodian} from "@openzeppelin/community-contracts/contracts/token/ERC20/extensions/ERC20Custodian.sol";
import {ERC20FlashMint} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

contract MyRWA is ERC20, ERC20Burnable, ERC20Pausable, AccessControl, ERC20Allowlist, ERC20Custodian, ERC20FlashMint {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant LIMITER_ROLE = keccak256("LIMITER_ROLE");
    bytes32 public constant CUSTODIAN_ROLE = keccak256("CUSTODIAN_ROLE");

    constructor(address defaultAdmin, address pauser, address minter, address limiter, address custodian)
        ERC20("MyRWA", "RWA")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
       
        _grantRole(MINTER_ROLE, minter);
        _grantRole(LIMITER_ROLE, limiter);
        _grantRole(CUSTODIAN_ROLE, custodian);
        allowUser(defaultAdmin);
         _mint(msg.sender, 5000 * 10 ** decimals());
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function allowUser(address user) public onlyRole(LIMITER_ROLE) {
        _allowUser(user);
    }

    function disallowUser(address user) public onlyRole(LIMITER_ROLE) {
        _disallowUser(user);
    }

    function _isCustodian(address user) internal view override returns (bool) {
        return hasRole(CUSTODIAN_ROLE, user);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Allowlist, ERC20Custodian)
    {
        super._update(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent)
        internal
        override(ERC20, ERC20Allowlist)
    {
        super._approve(owner, spender, value, emitEvent);
    }
}
