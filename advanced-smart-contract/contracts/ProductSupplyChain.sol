// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

import "./Ownable.sol";

// Interface for OnlyAdminCheck contract
interface IOnlyAdminCheck {
    function isAdmin(address administrator) external view returns (bool);
}

contract ProductSupplyChain is Ownable{

    IOnlyAdminCheck public onlyAdminCheck;
    address public admin; // owner of the contract
    enum ProductState { Created, Sold }

    //product struct
    struct Product{
        uint productId;
        string productName;
        address currentOwner;
        uint price;
        ProductState state;
    }

    constructor(address _onlyAdminCheckAddress) {
        admin = msg.sender;
        onlyAdminCheck = IOnlyAdminCheck(_onlyAdminCheckAddress);
    }

    //mapping of product id to product 
    mapping(uint => Product) public products;

    //mapping storing the owner of given product id.
    mapping(uint256 => mapping(address => bool)) public OWNER;

    event ProductCreated(uint256 productId, string name, address indexed owner, uint256 price);
    event ProductSold(uint256 productId, address indexed oldOwner, address indexed newOwner, uint256 price);
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    // modifier to restrict actions to product owner only.
    modifier onlyProductOwner(uint256 _productId) {
        require(OWNER[_productId][products[_productId].currentOwner], "Not Owner");
        _;
    }

    // check if product exists
    modifier productExists(uint _productId){
        require(products[_productId].productId != 0, "Product does not exist");
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
            productName: _name,
            currentOwner: msg.sender,
            price: _price,
            state: ProductState.Created
        });

        OWNER[_productId][msg.sender] = true; //adding the owner of the product in mapping.
    }

    function changeOwnership(address newOwner, uint256 _productId) private
     onlyOwner onlyValidAddress(newOwner) {

        address oldOwner = admin;
        OWNER[_productId][newOwner] = true; //adding the owner of the product in mapping.
        delete OWNER[_productId][msg.sender]; //deleting the old owner of the product.
        products[_productId].currentOwner = newOwner; //storing new owner in products mapping.

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function sellProduct(
        uint256 _productId, 
        address _newOwner) 
            public
            productExists(_productId) 
            onlyProductOwner(_productId) 
            onlyValidAddress(_newOwner)
        {
        
        require(products[_productId].state == ProductState.Created, "Product has already been sold");
        
        products[_productId].state = ProductState.Sold;
        address oldOwner = products[_productId].currentOwner;   
        changeOwnership(_newOwner, _productId); // changing the ownership of the product.

        emit ProductSold(_productId, oldOwner, _newOwner, products[_productId].price);
    }

    function getProductDetails(uint256 _productId) public view returns (Product memory) {
        return products[_productId];
    }
}