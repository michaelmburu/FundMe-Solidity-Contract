// SPDX-License-Identifier: MIT

//import solidity
pragma solidity >=0.6.6 <0.9.0;

//import chainlink
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol"; 

//import safemath
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol"; 


contract FundMe{

    //use safemath, not needed in v0.8>
    using SafeMathChainlink for uint256;

    //Map address to amounts funded
    mapping(address => uint256) public addressToAmountFunded;
    
    //Create funders array
    address[] public funders;
    //address of the one who deploys constract
    address public owner;
    //constructor
    //Add owner to contact
    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable{
        //Mandate $0.05ETH funding
        uint256 minimumUSD = 10 * 17;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more eth");

        //Keep track of addresses and amount they send
        addressToAmountFunded[msg.sender] += msg.value;

        //Add funders to array
        funders.push(msg.sender);

    }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUSD;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function withdraw() payable onlyOwner public {
        //only want contract admin/owner
        //require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
        //reset balance of all funders to zero
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reset funders array to zero
        funders = new address[](0);
    }
}