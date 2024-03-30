// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Interface for the ERC-20 token methods
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// Implementation contract for the ERC-20 token
contract TokenImplementation is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    address private _owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = _initialSupply * 10 ** uint256(decimals);
        _owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
    }


    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }


    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }


    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Additional functions can be added to enhance the token's functionality
}


// Proxy contract for the upgradeable ERC-20 token
contract TokenProxy is IERC20 {
    address public implementation;
    address private _owner;

    constructor(address _implementation) {
        implementation = _implementation;
        _owner = msg.sender;
    }


    function upgrade(address _newImplementation) external {
        require(msg.sender == _owner, "Only the owner can upgrade");
        implementation = _newImplementation;
    }


    fallback() external {
        address _impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }


    function totalSupply() external view override returns (uint256) {
        bytes memory payload = abi.encodeWithSignature("totalSupply()");
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (uint256));
    }


    function balanceOf(address account) external view override returns (uint256) {
        bytes memory payload = abi.encodeWithSignature("balanceOf(address)", account);
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (uint256));
    }


    function transfer(address recipient, uint256 amount) external override returns (bool) {
        bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)", recipient, amount);
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (bool));
    }


    function allowance(address owner, address spender) external view override returns (uint256) {
        bytes memory payload = abi.encodeWithSignature("allowance(address,address)", owner, spender);
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (uint256));
    }


    function approve(address spender, uint256 amount) external override returns (bool) {
        bytes memory payload = abi.encodeWithSignature("approve(address,uint256)", spender, amount);
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (bool));
    }


    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        bytes memory payload = abi.encodeWithSignature("transferFrom(address,address,uint256)", sender, recipient, amount);
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (bool));
    }


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        bytes memory payload = abi.encodeWithSignature("increaseAllowance(address,uint256)", spender, addedValue);
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (bool));
    }


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        bytes memory payload = abi.encodeWithSignature("decreaseAllowance(address,uint256)", spender, subtractedValue);
        (bool success, bytes memory data) = implementation.delegatecall(payload);
        require(success, "Delegatecall failed");
        return abi.decode(data, (bool));
    }

    // Additional functions can be added to enhance the token's functionality
}