
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FakeMoon {
    string public name = "FakeMoon";
    string public symbol = "FMN";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1_000_000_000 * 10**uint256(decimals);

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    uint256 public launchTime;
    address public owner;

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
        launchTime = block.timestamp;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _checkLimit(msg.sender, amount);
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address from, address to) public view returns (uint256) {
        return allowances[from][to];
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowances[from][msg.sender] >= amount, "Allowance too low");
        _checkLimit(from, amount);
        allowances[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Zero address");
        require(balances[from] >= amount, "Balance too low");
        balances[from] -= amount;
        balances[to] += amount;
        emit Transfer(from, to, amount);
    }

    function _checkLimit(address from, uint256 amount) internal view {
        if (block.timestamp <= launchTime + 30 minutes) {
            if (from == owner) return;
            require(amount <= totalSupply / 100, "Buy limit: max 1% in first 30 mins");
        }
    }
}
