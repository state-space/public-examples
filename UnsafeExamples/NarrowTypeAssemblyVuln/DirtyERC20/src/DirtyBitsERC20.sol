// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DirtyBitsERC20
 * @dev An ERC20 implementation demonstrating unsafe handling of narrow types in assembly
 * WARNING: This contract contains intentionally unsafe code for demonstration
 * DO NOT USE IN PRODUCTION
 */
contract DirtyBitsERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // Special fee configuration for transfers, using uint8 for percentages
    uint8 public transferFeePercent;
    address public feeCollector;
    
    constructor(
        string memory _name, 
        string memory _symbol, 
        uint8 _decimals, 
        uint256 initialSupply,
        uint8 _transferFeePercent
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        transferFeePercent = _transferFeePercent;
        feeCollector = msg.sender;
        
        _balances[msg.sender] = initialSupply;
        totalSupply = initialSupply;
        emit Transfer(address(0), msg.sender, initialSupply);
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev Calculate fee for a transfer amount
     */
    function calculateFee(uint256 amount) public view returns (uint256) {
        return (amount * transferFeePercent) / 100;
    }
    
    /**
     * @dev Transfer tokens with a fee
     */
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "Transfer to zero address");
        address from = msg.sender;
        
        uint256 fee = calculateFee(amount);
        uint256 netAmount = amount - fee;
        
        // Transfer net amount to recipient and fee to collector
        _balances[from] -= amount;
        _balances[to] += netAmount;
        
        if (fee > 0) {
            _balances[feeCollector] += fee;
            emit Transfer(from, feeCollector, fee);
        }
        
        emit Transfer(from, to, netAmount);
        return true;
    }
    
    /**
     * @dev BUG: Unsafe handling of narrow types in assembly
     * This function demonstrates the "dirty high bits" problem with uint8
     * When newFeePercent (uint8) is used directly in assembly without clearing high bits,
     * it can cause incorrect values to be stored if the high bits are dirty.
     */
    function setTransferFeePercent(uint8 newFeePercent) public {
        require(msg.sender == feeCollector, "Only fee collector can change fee");
        
        // UNSAFE: Storage write with potential dirty bits
        assembly {
            // newFeePercent from function parameter might have dirty high bits
            // When passed to assembly, these bits might not be properly cleared
            // Should use: newValue := and(newFeePercent, 0xff)
            let newValue := newFeePercent
            
            // Store without cleaning, potentially writing dirty bits to storage                    
            sstore(transferFeePercent.slot, newValue)
        }
    }
    
   
    // Standard ERC20 functions
    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        
        uint256 fee = calculateFee(amount);
        uint256 netAmount = amount - fee;
        
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += netAmount;
        
        if (fee > 0) {
            _balances[feeCollector] += fee;
            emit Transfer(from, feeCollector, fee);
        }
        
        emit Transfer(from, to, netAmount);
        return true;
    }
} 