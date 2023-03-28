// SPDX-License-Identifier: MIT
// DeFiMinds
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
}

contract Swap {
    address private constant MATIC_ADDRESS = 0x0000000000000000000000000000000000001010;
    address private constant WMATIC_ADDRESS = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;
    address private constant ETH_ADDRESS = 0x0000000000000000000000000000000000000000;
    address private constant WETH_ADDRESS = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address private constant WBTC_ADDRESS = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address private constant DAI_ADDRESS = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;
    address private constant UNISWAP_ROUTER_ADDRESS = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    mapping(address => mapping(address => uint256)) private _allowances;

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = msg.sender;
        require(spender != address(0), "Invalid spender address");
        require(owner != address(0), "Invalid owner address");
        _allowances[owner][spender] += addedValue;
        emit AllowanceChanged(owner, spender, _allowances[owner][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = msg.sender;
        require(spender != address(0), "Invalid spender address");
        require(owner != address(0), "Invalid owner address");
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "Allowance exceeded");
        _allowances[owner][spender] = currentAllowance - subtractedValue;
        emit AllowanceChanged(owner, spender, _allowances[owner][spender]);
        return true;
    }

    event AllowanceChanged(address indexed owner, address indexed spender, uint256 newAllowance);
    
    function swapMaticToWmatic(uint256 amountIn) public {
        address[] memory path = new address[](2);
        path[0] = MATIC_ADDRESS;
        path[1] = WMATIC_ADDRESS;
        _swap(amountIn, path);
    }

    function swapEthToWeth(uint256 amountIn) public {
        address[] memory path = new address[](2);
        path[0] = ETH_ADDRESS;
        path[1] = WETH_ADDRESS;
        _swap(amountIn, path);
    }

    function swapWethToWbtc(uint256 amountIn) public {
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = WBTC_ADDRESS;
        _swap(amountIn, path);
    }

    function swapWmaticToWbtc(uint256 amountIn) public {
        address[] memory path = new address[](3);
        path[0] = WMATIC_ADDRESS;
        path[1] = WETH_ADDRESS;
        path[2] = WBTC_ADDRESS;
        _swap(amountIn, path);
    }

    function swapDaiToMatic(uint256 amountIn) public {
        address[] memory path = new address[](2);
        path[0] = DAI_ADDRESS;
        path[1] = WMATIC_ADDRESS;
        uint256 maticAmount = _swap(amountIn, path);
        IERC20(MATIC_ADDRESS).transfer(msg.sender, maticAmount);
    }

function _swap(uint256 amountIn, address[] memory path) private returns (uint256) {
        require(path.length >= 2, "Invalid path");
        require(path[0] != address(0) && path[path.length - 1] != address(0), "Invalid address");
        IERC20 tokenIn = IERC20(path[0]);
        IERC20 tokenOut = IERC20(path[path.length - 1]);
        require(tokenIn.balanceOf(msg.sender) >= amountIn, "Insufficient balance");
        require(tokenIn.allowance(msg.sender, address(this)) >= amountIn, "Insufficient allowance");
        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        uint[] memory amounts = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS).swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp + 120
        );
        uint256 amountOut = amounts[amounts.length - 1];
        tokenOut.transfer(msg.sender, amountOut);
        return amountOut;
    }
}
