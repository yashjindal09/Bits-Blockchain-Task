// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ItemShop {
    struct Item {
        string name;
        string imageURL;
        string description;
        uint price; 
        uint quantity;
        address payable seller; 
    }

    Item[] public items;

    // Mapping to keep track of item availability
    mapping(uint => bool) public itemExistsMap;

    // Mapping to keep track of user balances
    mapping(address => uint) public balances;

    // Mapping to keep track of sellers
    mapping(address => bool) public sellers;

    // Owner of the contract
    address public owner;

    // Event to emit when a new item is added
    event ItemAdded(uint indexed itemId, string name, uint price, uint quantity, address indexed seller);

    // Event to emit when an item is purchased
    event ItemPurchased(address indexed buyer, uint indexed itemId, uint quantity, uint totalPrice, address indexed seller);

    // Event to emit when the owner withdraws ETH
    event Withdraw(address indexed owner, uint amount);

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
        sellers[msg.sender] = true; // Owner is also a seller by default
    }

    // Modifier to check if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Modifier to check if the caller is a registered seller
    modifier onlySeller() {
        require(sellers[msg.sender], "Only registered sellers can call this function");
        _;
    }

    // Modifier to check if an item exists
    modifier itemExists(uint itemId) {
        require(itemExistsMap[itemId], "Item does not exist");
        _;
    }

    // Function to add a new item to the shop
    function addItem(string memory _name, string memory _imageURL, string memory _description, uint _price, uint _quantity) external onlySeller {
        uint itemId = items.length;
        items.push(Item(_name, _imageURL, _description, _price, _quantity, payable(msg.sender))); // Added payable to seller
        itemExistsMap[itemId] = true;
        emit ItemAdded(itemId, _name, _price, _quantity, msg.sender);
    }

    // Function to get details of an item
    function getItem(uint itemId) external view itemExists(itemId) returns (string memory name, string memory imageURL, string memory description, uint price, uint quantity, address seller) {
        Item storage item = items[itemId];
        return (item.name, item.imageURL, item.description, item.price, item.quantity, item.seller);
    }

    // Function to purchase items
    function purchaseItem(uint itemId, uint quantity) external payable itemExists(itemId) {
        Item storage item = items[itemId];
        require(item.quantity >= quantity, "Not enough quantity available");
        uint totalPrice = item.price * quantity;
        require(msg.value >= totalPrice, "Insufficient funds");

        item.quantity -= quantity;
        balances[item.seller] += totalPrice;
        balances[msg.sender] -= totalPrice;

        emit ItemPurchased(msg.sender, itemId, quantity, totalPrice, item.seller);
    }

    // Function to withdraw ETH from the contract
    function withdraw(uint amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner).transfer(amount);
        emit Withdraw(owner, amount);
    }

    // Function to register as a seller
    function registerAsSeller() external {
        sellers[msg.sender] = true;
    }

    // Function to unregister as a seller
    function unregisterAsSeller() external {
        delete sellers[msg.sender];
    }

    // Function to check if an address is a seller
    function isSeller(address _address) external view returns (bool) {
        return sellers[_address];
    }
}
