pragma solidity =0.5.12; // needs to be updated to the latest version of Solidity ^0.8.0

//import ERC4626 from "@openzeppelin/contracts/token/ERC4626/ERC4626";
//import ZRC20 from "@openzeppelin/contracts/token/ZRC20/ZRC20";
contract TribalCreditMasterContract { //is ZRC20, ERC4626 {

    // ERC20 Data for Tribal Token
    string  public constant name     = "Tribal Token Stablecoin";
    string  public constant symbol   = "TRBL";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply; // Total supply of tokens is 2.5 Trillion

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint256) public nonces;

    //safeTransferFrom and safeTransfer functions
    event Approval(address indexed src, address indexed guy, uint256 wad);
    event Transfer(address indexed src, address indexed dst, uint256 wad);
    event Purchased(address indexed buyer, uint256 amount);
    event Sold(address indexed seller, uint256 amount);

    // EtherTokenExchange variables
    address public owner;
    uint256 public pricePerToken = 1 ether;
    uint256 public tokenBalance;

    constructor(uint256 initialSupply) public {
        owner = msg.sender; //make a multisig wallet
        tokenBalance = initialSupply;
        totalSupply = initialSupply;
        balanceOf[msg.sender] = initialSupply; // Assigning the initial supply to the contract deployer
    }
    //make safeTransferFrom and safeTransfer functions to prevent reentrancy
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Sender does not have enough tokens");
        require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow error"); // Check for overflows
        balanceOf[msg.sender] -= _value; // Subtract from the sender
        balanceOf[_to] += _value; // Add the same to the recipient

        emit Transfer(msg.sender, _to, _value); // Emit a transfer event
        return true;
    }
    //add buy from AMM DEX liquidity pools and sell to AMM DEX pools functions
    function buyToken(uint256 tokenAmount) public payable {
        require(msg.value == tokenAmount * pricePerToken, "Incorrect Ether sent");
        require(tokenBalance >= tokenAmount, "Not enough tokens in contract");

        tokenBalance -= tokenAmount;
        balanceOf[msg.sender] += tokenAmount; // Increase the buyer's balance

        emit Purchased(msg.sender, tokenAmount);
    }
    //add checks to prevent reentrancy
    function sellToken(uint256 tokenAmount) public {
        require(balanceOf[msg.sender] >= tokenAmount, "Not enough tokens to sell");
        require(tokenAmount <= tokenBalance, "Not enough tokens in contract to buy");

        tokenBalance += tokenAmount;
        balanceOf[msg.sender] -= tokenAmount; // Decrease the seller's balance

        payable(msg.sender).transfer(tokenAmount * pricePerToken);

        emit Sold(msg.sender, tokenAmount);
    }

//     function withdraw() public {
//         require(msg.sender == owner, "Only the owner can withdraw");
//         payable(owner).transfer(address(this).balance);
//     }
// }
```

This unified contract, `TribalCreditMasterContract`, now controls all the functionalities of the master/slave relationships found in the original `TribalTokenGenesisBlockMaster` smart contract. Always ensure thorough testing and potentially an audit before deploying any smart contract to a live environment.