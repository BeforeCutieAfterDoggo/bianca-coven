// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Worthless721 is ERC721 {
    uint256 public tokenId = 1;

    constructor() ERC721("Worthless721", "W721") { }

    function mint() public {
        _safeMint(msg.sender, tokenId);
        tokenId++;
    }
}
