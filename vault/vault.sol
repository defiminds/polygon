// SPDX-License-Identifier: MIT
// DeFiMinds
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DepositWithdraw {
    mapping(address => mapping(address => uint256)) private _balances;

    function deposit(address token, uint256 amount) public {
        require(token == 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270 || // WMATIC
                token == 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619 || // WETH
                token == 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063 || // DAI
                token == 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6,  // WBTC
                "Token not supported"); // Ensure token is supported
        require(amount > 0, "Amount must be greater than zero");
        IERC20(token).transfer(address(this), amount);
        _balances[msg.sender][token] += amount;
    }

    function withdraw(address token, uint256 amount) public {
        require(_balances[msg.sender][token] >= amount, "Insufficient balance");
        IERC20(token).transfer(msg.sender, amount);
        _balances[msg.sender][token] -= amount;
    }

    function balanceOf(address account, address token) public view returns (uint256) {
        return _balances[account][token];
    }
}
