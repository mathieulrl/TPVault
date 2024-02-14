// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/IERC4626.sol)

pragma solidity ^0.8.20;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title Vault Contract
*/

contract MyVault is ERC4626 {

    address private constant POOL_ADDRESS_PROVIDER = 0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A;
    address constant USDC_ADDRESS = 0x16dA4541aD1807f4443d92D26044C1147406EB80;

    address private AAVE_LENDING_POOL_ADDRESS; 
    address private PRICE_ORACLE;

    mapping(address => uint256) public balances;
    IPool private lendingPool;
    IPriceOracle private priceOracle;


    /*//////////////////////////////////////////////////////////////
                               IMMUTABLE
    //////////////////////////////////////////////////////////////*/


    constructor(
        ERC20 _token,
        string memory _name,
        string memory _symbol
    ) ERC4626(_token, _name, _symbol) {
        IPoolAddressesProvider provider = IPoolAddressesProvider(POOL_ADDRESS_PROVIDER);
        AAVE_LENDING_POOL_ADDRESS = provider.getPool();
        lendingPool = IPool(AAVE_LENDING_POOL_ADDRESS);
        priceOracle = IPriceOracle(PRICE_ORACLE);
    }



    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Deposit assets into the GhostVault and mint corresponding shares.
     * @param assets The amount of assets to deposit.
     * @param receiver The address to receive the minted shares.
     * @return shares The number of shares minted.
     */
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256 shares) {
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
        asset.transferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }

    /**
     * @dev Withdraw assets from the GhostVault and burn corresponding shares.
     * @param assets The amount of assets to withdraw.
     * @param receiver The address to receive the withdrawn assets.
     * @param owner The owner of the shares being burned.
     * @return shares The number of shares burned.
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual override returns (uint256 shares) {
        shares = previewWithdraw(assets);
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender];
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        beforeWithdraw(assets,
        shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.transferFrom(address(this), receiver, assets);
    }

    /**
     * @dev Perform actions after depositing assets into the GhostVault.
     * @param assets The amount of assets deposited.
     
     */
    function afterDeposit(uint256 assets, uint256 /*shares*/) internal virtual override {
        // Approve lending pool to use tokens from this smart contract
        asset.approve(AAVE_LENDING_POOL_ADDRESS, assets);

        // Deposit tokens to the Aave lending pool
        lendingPool.supply(address(asset), assets, address(this), 0);
    }

    /**
     * @dev Perform actions before withdrawing assets from the GhostVault.
     * @param assets The amount of assets to withdraw.
     */
    function beforeWithdraw(uint256 assets, uint256 /*shares*/) internal virtual override {
        // Withdraw tokens directly from Aave to user
        lendingPool.withdraw(address(asset), assets, msg.sender);
    }



    
    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Get the total assets held by the GhostVault.
     * @return The total amount of assets held.
     */
    function totalAssets() public view virtual override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    /**
     * @dev Convert the given amount of assets to shares.
     * @param assets The amount of assets to convert.
     * @return The number of shares corresponding to the given assets.
     */
    function convertToShares(uint256 assets) public view virtual override returns (uint256) {
        uint256 supply = assets;
        return supply;
    }

    /**
     * @dev Convert the given number of shares to assets.
     * @param shares The number of shares to convert.
     * @return The amount of assets corresponding to the given shares.
     */
    function convertToAssets(uint256 shares) public view virtual override returns (uint256) {
        uint256 supply = shares;
        return supply;
    }

    /**
     * @dev Preview the number of shares that will be minted for the given amount of assets.
     * @param assets The amount of assets to deposit.
     * @return The number of shares that will be minted.
     */
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        return convertToShares(assets);
    }

    /**
     * @dev Preview the number of shares that will be burned for the given amount of assets to withdraw.
     * @param assets The amount of assets to withdraw.
     * @return The number of shares that will be burned.
     */
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        uint256 supply = assets;
        return supply;
    }

    /**
     * @dev Preview the amount of assets that will be redeemed for the given number of shares.
     * @param shares The number of shares to redeem.
     * @return The amount of assets that will be redeemed.
     */
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        return convertToAssets(shares);
    }


    /*//////////////////////////////////////////////////////////////
                            HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /**
     * @dev Get the price of the asset held by the GhostVault.
     * @return The price of the asset.
     */
    function getAssetPrice( ) public view  returns (uint256) {

        return priceOracle.getAssetPrice(USDC_ADDRESS);

    }

        
}