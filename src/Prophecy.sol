// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "forge-std/console2.sol";

contract ERC721Contract {
    function balanceOf(address addr) public view returns (uint256) { }
    function ownerOf(uint256 tokenId) public view returns (address) { }
    function safeTransferFrom(address from, address to, uint256 tokenId) public { }
    function transferFrom(address from, address to, uint256 tokenId) public { }
}

contract Prophecy is ERC721, Pausable, Ownable {
    using Counters for Counters.Counter;

    address public covenAddr;
    address public signAddr;

    Counters.Counter private _tokenIdCounter;

    constructor(address _covenAddr, address _signAddr) ERC721("RIP my NFT", "RIP") {
        covenAddr = _covenAddr;
        signAddr = _signAddr;
    }

    function onERC721Received(
        address,
        address from,
        uint256 id,
        bytes calldata data
    )
        external
        whenNotPaused
        returns (bytes4)
    {
        // decode and print data
        handleTokenReceived(from, id, data);
        return IERC721Receiver.onERC721Received.selector;
    }

    function handleTokenReceived(
        address transferFrom,
        uint256 transferTokenId,
        bytes calldata data
    )
        private
        whenNotPaused
    {
        // decode the data
        (address owner, address tokenContract, uint256 tokenId) = abi.decode(data, (address, address, uint256));

        require(owner == transferFrom, "NOT_OWNER");
        require(msg.sender == tokenContract, "NOT_CONTRACT");
        require(transferTokenId == tokenId, "NOT_ID");
        require(doWeOwnIt(tokenContract, tokenId), "NOT_TRANSFERED");
        sendToCoven(tokenContract, tokenId);

        _safeMint(owner, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function doWeOwnIt(address contractAddr, uint256 tokenId) private view returns (bool) {
        ERC721Contract cont = ERC721Contract(contractAddr);
        return (cont.ownerOf(tokenId) == address(this));
    }

    function sendToCoven(address contractAddr, uint256 tokenId) private {
        console2.log("Sending to coven");
        ERC721Contract cont = ERC721Contract(contractAddr);
        cont.safeTransferFrom(address(this), covenAddr, tokenId);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}
