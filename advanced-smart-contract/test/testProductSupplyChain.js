const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('ProductSupplyChain', function () {
  let owner, newOwner, otherAccount1,otherAccount2;
  let productSupplyChain;

  before(async function () {
    // Get contract signers
    [owner, newOwner, otherAccount1,otherAccount2] = await ethers.getSigners();

    // Deploy OnlyAdminCheck contract
    const OnlyAdminCheck = await ethers.deployContract('OnlyAdminCheck');
    const onlyAdminCheck = await OnlyAdminCheck.waitForDeployment();

    // Deploy ProductSupplyChain contract with OnlyAdminCheck address
    const ProductSupplyChain = await ethers.deployContract('ProductSupplyChain',[onlyAdminCheck.target]);
    productSupplyChain = await ProductSupplyChain.waitForDeployment();
  });

  describe('createProduct', function () {
    it('should allow only the owner to create a product', async function () {
      const productId = 1;
      const productName = 'Test Product';
      const price = 100;

      // Non-owner attempting to create a product should revert
     // await expect(productSupplyChain.connect(otherAccount1).createProduct(productId, productName, price)).to.be.revertedWith('Not Owner');

      // Ensure successfull creation of a product
      await productSupplyChain.connect(owner).createProduct(productId, productName, price);

            // Retrieve product details and check ownership
            const product = await productSupplyChain.products(1);
            const isOwner = await productSupplyChain.OWNER(1, owner);
      
            // Validate product details and ownership
            expect(product.productId).to.equal(1);
            expect(isOwner).to.equal(true);      
    });

    it("should not allow creation of a product with an existing ID", async function () {
      const productId = 1;
      const productName = "AnotherProduct";
      const price = 2;
    
      await expect(productSupplyChain.connect(owner).createProduct(productId, productName, price)).to.be.revertedWith(
            "Product ID already exists"
      );
  });
  });


  describe('sellProduct', function () {
    it('should allow only the owner to sell a product', async function () {
      const productId = 1;

      // Owner selling a product should update product details and emit ProductSold event
      await productSupplyChain.sellProduct(productId, newOwner.address);

      // Verify that the product is sold correctly
      const product = await productSupplyChain.products(productId);
      expect(product.currentOwner).to.equal(newOwner.address);
      expect(product.state).to.equal(1);
    });

    it("should not allow non-owners to sell a product", async function () {
      const productId = 2;
      const newOwner = otherAccount1.address;

      await productSupplyChain.createProduct(productId, "Test Product", 55n);
      await expect(productSupplyChain.connect(otherAccount2).sellProduct(productId, newOwner)).to.be.revertedWith(
        "Not Owner"
      );
    });

    it("should not allow selling a non-existing product", async function () {
      const productId = 55;

      await productSupplyChain.createProduct(6, "Test Product", 10);

      await expect(productSupplyChain.sellProduct(productId, newOwner.address)).to.be.revertedWith(
        "Product does not exist"
      );
    });
  });
});


