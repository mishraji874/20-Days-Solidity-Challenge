// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DecentralizedExchange {
    address public admin;
    uint256 public feeRate;
    uint256 public nextOrderId;
    enum OrderType { BUY, SELL }
    struct Order {
        uint256 id;
        address trader;
        OrderType orderType;
        address token;
        uint256 amount;
        uint256 price;
    }

    mapping(uint256 => Order) public orders;
    mapping(address => mapping(address => uint256)) public balances;
    
    event OrderPlaced(uint256 orderId, address indexed trader, OrderType orderType, address indexed token, uint256 amount, uint256 price);
    event OrderMatched(uint256 buyOrderId, uint256 sellOrderId, uint256 amount, uint256 price);
    event OrderCanceled(uint256 orderId);
    event FeeCollected(address indexed collector, uint256 amount);

    constructor(uint256 _feeRate) {
        admin = msg.sender;
        feeRate = _feeRate;
        nextOrderId = 1;
    }


    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _ ;
    }


    function placeOrder(OrderType _orderType, address _token, uint256 _amount, uint256 _price) external {
        require(_orderType == OrderType.BUY || _orderType == OrderType.SELL, "Invalid order type");
        require(_amount > 0, "Amount must be greater than zero");
        require(_price > 0, "Price must be greater than zero");
        uint256 orderId = nextOrderId++;
        orders[orderId] = Order(orderId, msg.sender, _orderType, _token, _amount, _price);
        emit OrderPlaced(orderId, msg.sender, _orderType, _token, _amount, _price);
        if (_orderType == OrderType.BUY) {
            // If it's a buy order, lock the required tokens
            require(IERC20(_token).transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        } else {
            // If it's a sell order, lock the required Ether
            require(msg.value >= _amount * _price, "Insufficient Ether sent");
            balances[msg.sender][_token] += _amount;
        }
    }


    function cancelOrder(uint256 _orderId) external {
        Order storage order = orders[_orderId];
        require(order.trader == msg.sender, "Only the order owner can cancel");
        require(order.id == _orderId, "Order not found");
        emit OrderCanceled(_orderId);
        if (order.orderType == OrderType.SELL) {
            // If it's a sell order, return the locked tokens to the trader
            require(IERC20(order.token).transfer(msg.sender, order.amount), "Token transfer failed");
        }
        delete orders[_orderId];
    }


    function matchOrders(uint256 _buyOrderId, uint256 _sellOrderId, uint256 _amount, uint256 _price) external {
        Order storage buyOrder = orders[_buyOrderId];
        Order storage sellOrder = orders[_sellOrderId];
        require(buyOrder.id == _buyOrderId, "Buy order not found");
        require(sellOrder.id == _sellOrderId, "Sell order not found");
        require(buyOrder.orderType == OrderType.BUY, "Invalid buy order");
        require(sellOrder.orderType == OrderType.SELL, "Invalid sell order");
        require(buyOrder.price >= _price, "Buy price is lower than expected");
        require(sellOrder.price <= _price, "Sell price is higher than expected");
        require(buyOrder.token == sellOrder.token, "Tokens do not match");
        require(_amount <= buyOrder.amount, "Buy order amount exceeded");
        require(_amount <= sellOrder.amount, "Sell order amount exceeded");

        // Transfer the matched amount of tokens
        uint256 fee = (_amount * _price * feeRate) / 10000;
        // Transfer tokens from the seller to the buyer
        require(IERC20(buyOrder.token).transferFrom(sellOrder.trader, buyOrder.trader, _amount), "Token transfer failed");
        // Transfer Ether from the buyer to the seller, excluding the fee
        payable(sellOrder.trader).transfer(_amount * _price - fee);
        // Transfer the fee to the admin
        payable(admin).transfer(fee);
        // Update order amounts and emit a match event
        buyOrder.amount -= _amount;
        sellOrder.amount -= _amount;
        emit OrderMatched(_buyOrderId, _sellOrderId, _amount, _price);
        // If any of the orders are fully matched, delete them
        if (buyOrder.amount == 0) {
            delete orders[_buyOrderId];
        }
        if (sellOrder.amount == 0) {
            delete orders[_sellOrderId];
        }
    }


    function withdrawToken(address _token, uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender][_token] >= _amount, "Insufficient balance");
        balances[msg.sender][_token] -= _amount;
        require(IERC20(_token).transfer(msg.sender, _amount), "Token transfer failed");
    }


    function withdrawEther(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(msg.sender).transfer(_amount);
    }
}