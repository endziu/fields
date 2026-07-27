// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test, stdStorage, StdStorage } from "forge-std/Test.sol";
import { DeployFields } from "../script/DeployFields.s.sol";
import { Fields } from "../src/Fields.sol";

contract AddAssetsTest is Test {
    using stdStorage for StdStorage;

    Fields public fields;
    DeployFields public deployer;

    function setUp() public {
        deployer = new DeployFields();
        fields = deployer.run();
    }

    function testAddAssetOnlyOwner() public {
        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        bytes32[] memory assetsToAdd = new bytes32[](1);
        assetsToAdd[0] = bytes32("nft4");
        fields.addAssets(assetsToAdd);
    }

    function testAddAssetCollectionSizeIncrease() public {
        uint256 collectionSize = stdstore.target(address(fields)).sig(fields.collectionSize.selector).find();
        uint256 initBalance = uint256(vm.load(address(fields), bytes32(collectionSize)));

        vm.deal(address(fields.owner()), 1 ether);
        vm.prank(address(fields.owner()));

        bytes32[] memory assetsToAdd = new bytes32[](1);
        assetsToAdd[0] = bytes32("nft4");
        fields.addAssets(assetsToAdd);
        uint256 finalBalance = uint256(vm.load(address(fields), bytes32(collectionSize)));
        assertGt(finalBalance, initBalance);
    }

    function testAddAssetAlreadyExists() public {
        vm.startPrank(address(fields.owner()));

        bytes32[] memory assetsToAdd = new bytes32[](1);
        assetsToAdd[0] = bytes32("nft4");
        fields.addAssets(assetsToAdd);

        vm.expectRevert(Fields.DuplicateAsset.selector);
        fields.addAssets(assetsToAdd);
        vm.stopPrank();
    }

    function testAddAssetPastSupplyCap() public {
        vm.prank(address(fields.owner()));
        // deployer seeds 3 assets, so pushing collectionSize above MAX_SUPPLY (256) requires 254 more.
        bytes32[] memory assetsToAdd = new bytes32[](254);
        for (uint256 i = 0; i < assetsToAdd.length; i++) {
            assetsToAdd[i] = bytes32(uint256(i + 1));
        }
        vm.expectRevert(Fields.SupplyCapReached.selector);
        fields.addAssets(assetsToAdd);
    }

    function testAddAssetIsForSale() public {
        bytes32 itemHash = keccak256(abi.encodePacked("nft4"));
        assertEq(bool(fields.isForSale(itemHash)), false);

        bytes32[] memory assetsToAdd = new bytes32[](1);
        assetsToAdd[0] = bytes32(itemHash);

        vm.prank(address(fields.owner()));
        fields.addAssets(assetsToAdd);

        assertEq(bool(fields.isForSale(itemHash)), true);
    }

    function testAddAssetEmmitEvent() public {
        ExpectEmit expectEmit = new ExpectEmit();
        vm.prank(address(expectEmit));
        vm.deal(address(fields.owner()), 1 ether);
        vm.prank(address(fields.owner()));
        bytes32[] memory assetsToAdd = new bytes32[](1);
        assetsToAdd[0] = bytes32("nft4");
        fields.addAssets(assetsToAdd);
        expectEmit.addAssetEvent();
    }
}

contract ExpectEmit {
    event AddAsset(string asset);
    event Mint(address indexed minter, string uri, uint256 id);

    function addAssetEvent() public {
        emit AddAsset("nft4");
    }

    function mintEvent() public {
        emit Mint(address(this), "nft4", 0);
    }
}
