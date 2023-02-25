// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import "./mock/Worthless721.sol";
import "../src/Prophecy.sol";

contract ProphecyTest is PRBTest, StdCheats {
    address internal _theCoven = address(bytes20(keccak256("the-coven")));
    address internal _generousPatron = address(bytes20(keccak256("generous-patron")));
    address internal _burnAddress = address(bytes20(keccak256("BCAD")));

    Worthless721 internal _worthless721;
    Prophecy internal _prophecy;

    function setUp() public {
        vm.label(_theCoven, "the-coven");
        vm.label(_generousPatron, "generous-patron");

        vm.deal(_theCoven, 100 ether);
        vm.deal(_generousPatron, 100 ether);

        _worthless721 = new Worthless721();
        // Mint a worthless NFT to the generous patron
        vm.prank(_generousPatron);
        _worthless721.mint();

        _prophecy = new Prophecy(_theCoven, _theCoven);
    }

    function testProphecy() public {
        assertEq(_worthless721.balanceOf(_generousPatron), 1, "generous patron should have 1 worthless NFT");

        // Transfer the worthless NFT to the Prophecy contract
        vm.startPrank(_generousPatron);
        bytes memory data = abi.encode(address(_generousPatron), address(_worthless721), 1);
        _worthless721.safeTransferFrom(_generousPatron, address(_prophecy), 1, data);

        // This should make the coven the owner of the worthless NFT
        assertEq(_worthless721.balanceOf(_theCoven), 1, "the coven should have 1 worthless NFT");

        // The Generous Patron should have 1 Prophecy token
        assertEq(_prophecy.balanceOf(_generousPatron), 1, "generous patron should have 1 Prophecy token");
    }
}
