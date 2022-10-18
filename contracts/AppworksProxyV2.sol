// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AppWorksProxyV2 is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    using Strings for uint256;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _nextTokenId;

    uint256 public price;
    uint256 public constant maxSupply = 100;
    uint256 public userMaxMintAmount;
    uint256 public ownerMaxMintAmount;
    
    bool public mintActive;
    bool public earlyMintActive;
    bool public revealed;
    
    string public baseURI;
    string private _blindTokenURI;
    bytes32 public merkleRoot;

    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) public addressMintedBalance;

    function initialize() initializer public {
        __ERC721_init("AppWorks", "AW");
        price = 0.01 ether;
        mintActive = false;
        earlyMintActive = false;
        revealed = false;
        userMaxMintAmount = 10;
        ownerMaxMintAmount = 20;
    }

    function mint(uint256 _mintAmount) public payable {
        //Current state is available for Public Mint
        require(mintActive, "mint is not available");

        //Check how many NFTs are available to be minted
        require(maxSupply - totalSupply() >= _mintAmount, "available mint amount not enough");

        //Check user has sufficient funds
        require(msg.value >= _mintAmount * price);

        //Check mint amount > 0
        require(_mintAmount > 0, "mint amount must > 0");

        if(msg.sender == owner()) {
            require(addressMintedBalance[msg.sender] + _mintAmount <= 20, "limitation of owner mint amount is 20");
        } else {
            require(addressMintedBalance[msg.sender] + _mintAmount <= 10, "limitation of user mint amount is 10");
        }

        //start mint
        //state update first, then send transaction.
        uint nextTokenId = _nextTokenId.current();
        for (uint i = 0; i < _mintAmount; i++) {
            nextTokenId++;
            addressMintedBalance[msg.sender]++;
            _safeMint(msg.sender, nextTokenId);
        }
        _nextTokenId._value = nextTokenId;
    }
  
    function totalSupply() view public returns (uint) {
        return _nextTokenId.current();
    }

    function withdrawBalance() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function setPrice(uint _price) public onlyOwner {
        price = _price;
    }
    
    function toggleMint() public onlyOwner {
        mintActive = !mintActive;
    }

    function toggleReveal() public onlyOwner {
        revealed = !revealed;
    }

    function setBaseURI(string calldata newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function toggleEarlyMint() public onlyOwner {
        earlyMintActive = !earlyMintActive;
    }

    // Early mint function for people on the whitelist
    function earlyMint(bytes32[] calldata _merkleProof, uint256 _mintAmount) public payable {

        //Get leaf by hash msg.sender
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        //Put _merkleProof and leaf in, and MerkleProof.verify() will verify 
        //if the hash result is equal to merkleRoot or not.
        require(MerkleProofUpgradeable.verify(_merkleProof, merkleRoot, leaf), "invalid proof");

        mint(_mintAmount);
    }
    
    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    //return real tokenUri or blind tokenUri according to the revealed flag
    function getTokenURI(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        _requireMinted(tokenId);
        if (revealed) {
            string memory baseURI = _baseURI();
            return
                bytes(baseURI).length > 0
                    ? string(
                        abi.encodePacked(baseURI, tokenId.toString(), ".json")
                    )
                    : "";
        } else {
            return _blindTokenURI;
        }
    }

    function setBlindTokenUri(string calldata newUri) public onlyOwner {
        _blindTokenURI = newUri;
    }


    // Let this contract can be upgradable, using openzepplin proxy library - week 10
    // Try to modify blind box images by using proxy
    
}