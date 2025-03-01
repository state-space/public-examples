// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Allowlist} from "@openzeppelin/community-contracts/contracts/token/ERC20/extensions/ERC20Allowlist.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Custodian} from "@openzeppelin/community-contracts/contracts/token/ERC20/extensions/ERC20Custodian.sol";
import {ERC20FlashMint} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyRWA is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20FlashMint, ERC20Custodian, ERC20Allowlist {
    constructor(address initialOwner)
        ERC20("MyRWA", "RWA")
        Ownable(initialOwner)
    {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _isCustodian(address user) internal view override returns (bool) {
        return user == owner();
    }

    function allowUser(address user) public onlyOwner {
        _allowUser(user);
    }

    function disallowUser(address user) public onlyOwner {
        _disallowUser(user);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Custodian, ERC20Allowlist)
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
