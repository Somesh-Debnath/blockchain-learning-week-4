// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Interface for OnlyAdminCheck contract
interface IOnlyAdminCheck {
    function isAdmin(address administrator) external view returns (bool);
}

contract ProductSupplyChain is Ownable,AccessControl{

    IOnlyAdminCheck public onlyAdminCheck;
    //product struct
    struct Product{
        uint productId;
        string productName;
        string currentOwner;
        uint price;
        string state;
    }

    constructor(address _onlyAdminCheckAddress) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        onlyAdminCheck = IOnlyAdminCheck(_onlyAdminCheckAddress);

    }

    //mapping of product id to product 
    mapping(uint => Product) public products;

    event ProductCreated(uint256 productId, string name, address indexed owner, uint256 price);
    event ProductSold(uint256 productId, address indexed oldOwner, address indexed newOwner, uint256 price);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   //only admin can add product
   modifier onlyOwnerOfProduct(uint _productId){
       require(msg.sender == products[_productId].currentOwner);
       _;
    }
    // check if product exists
    modifier productExists(uint _productId){
        require(products[_productId].productId != 0);
        _;
    }

    // check if address is valid
    modifier onlyValidAddress(address user) {
       require(user != address(0), "Invalid address");
        _;
    }

    function createProduct(uint256 _productId, string memory _name, uint256 _price) external onlyOwner {
        require(products[_productId].productId == 0, "Product ID already exists");

        // create product
        products[_productId] = Product({
            productId: _productId,
            name: _name,
            currentOwner: msg.sender,
            price: _price,
            state: 0
        });
    }

    function transferOwnership(address newOwner, uint _productId) external onlyOwner onlyValidAddress(newOwner) {
        require(products[_productId].productId != 0, "Product ID does not exist");
        require(products[_productId].currentOwner == msg.sender, "Only the owner can transfer ownership");

        // transfer ownership of product
        products[_productId].currentOwner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }

    function sellProduct(
        uint256 _productId, 
        address _newOwner) 
            external 
            onlyOwnerOfProduct(_productId) 
            productExists(_productId) 
            onlyValidAddress(_newOwner)
        {
        
        Product storage product = products[_productId];
        address oldOwner = product.currentOwner;
        transferOwnership(_newOwner, _productId);
        product.state = 1; // State 1 means product is sold

        emit ProductSold(_productId, oldOwner, _newOwner, product.price);
    }

}