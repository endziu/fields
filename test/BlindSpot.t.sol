// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { Fields } from "../src/Fields.sol";
import { DeployFields } from "../script/DeployFields.s.sol";

contract BlindSpotTest is Test {
    Fields public fields;

    function testConstructorBypassSupplyCap() public {
        // defined MAX_SUPPLY is 10
        bytes32[] memory assets = new bytes32[](11);
        for(uint256 i = 0; i < 11; i++) {
            assets[i] = bytes32(uint256(i + 1));
        }
        
        // This should NOT revert if my hypothesis is true
        fields = new Fields(assets);
        
        // Check collection size
        assertEq(fields.collectionSize(), 11);
    }

    function testReAddSoldAsset() public {
        bytes32[] memory assets = new bytes32[](1);
        string memory uri = "bafkreidcapki3wfwy356um7wvwiud4cpnrucnuumtlw6g3fjx6eswynlx4";
        bytes32 uriHash = keccak256(abi.encodePacked(uri));
        assets[0] = uriHash;

        fields = new Fields(assets); // collectionSize = 1

        // Mint it
        vm.deal(address(this), 1 ether);
        fields.safeMint{value: 0.1 ether}(uri);

        // Verify it's not for sale
        (bool forSale) = fields.isForSale(uriHash);
        assertFalse(forSale);

        // Owner adds it again
        fields.addAssets(assets);

        // Should be for sale again and collectionSize increased?
        (bool forSaleAgain) = fields.isForSale(uriHash);
        assertTrue(forSaleAgain);
        assertEq(fields.collectionSize(), 2);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

