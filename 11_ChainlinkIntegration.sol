//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract WeatherContract is ChainlinkClient {
    using Chainlink for Chainlink.Request;
    string public weatherData;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    constructor() {
        setPublicChainlinkToken();
        oracle = //replace with your Chainlink oracle id
        jobId = //replace with your Chainlink job id
        fee =  0.1 * 10 ** 18;
    }

    function requestWeatherData() public {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        request.add("get", "https://api.example.com/weather"); //replace with your api source
        request.add("path", "main.temp"); //replace with your desired data field
        sendChainlinkrequestTo(oracle, request, fee);
    }

    function fulfill(bytes32 _requestId, string memory _data) public recordChainlinkFulfillment(_requestId) {
        weatherData = _data;
    }

    function isWeatherGood() public view returns (bool) {
        int256 tempreature = parseInt(weatherData, 1); //convert string to int
        return tempreature > 25;
    }
}