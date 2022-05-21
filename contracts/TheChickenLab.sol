// SPDX-License-Identifier: MIT
//
//
//
//████████╗██╗  ██╗███████╗     ██████╗██╗  ██╗██╗ ██████╗██╗  ██╗███████╗███╗   ██╗    ██╗      █████╗ ██████╗ 
//╚══██╔══╝██║  ██║██╔════╝    ██╔════╝██║  ██║██║██╔════╝██║ ██╔╝██╔════╝████╗  ██║    ██║     ██╔══██╗██╔══██╗
//   ██║   ███████║█████╗      ██║     ███████║██║██║     █████╔╝ █████╗  ██╔██╗ ██║    ██║     ███████║██████╔╝
//   ██║   ██╔══██║██╔══╝      ██║     ██╔══██║██║██║     ██╔═██╗ ██╔══╝  ██║╚██╗██║    ██║     ██╔══██║██╔══██╗
//   ██║   ██║  ██║███████╗    ╚██████╗██║  ██║██║╚██████╗██║  ██╗███████╗██║ ╚████║    ███████╗██║  ██║██████╔╝
//   ╚═╝   ╚═╝  ╚═╝╚══════╝     ╚═════╝╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝    ╚══════╝╚═╝  ╚═╝╚═════╝ 
//                                                                                                              
//                                                                               
//
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract TheChickenLab is ERC721A, Ownable{
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 250;
    uint256 public constant MAX_PUBLIC_MINT = 1;
    uint256 public constant MAX_WHITELIST_MINT = 1;
    uint256 public constant PUBLIC_SALE_PRICE = 0.05 ether;
    uint256 public constant WHITELIST_SALE_PRICE = 0 ether;

    string private  baseTokenUri;
    string public   placeholderTokenUri;
    bytes32 private merkleRoot;
    
    bool public isRevealed;
    bool public publicSale;
    bool public whiteListSale;
    bool public pause;

   
    mapping(address => uint256) public totalPublicMint;
    mapping(address => uint256) public totalWhitelistMint;

    constructor() ERC721A("TheChickenLab", "CKN"){ 
    }
    
    // Only users can interact with the contract, other contract are not allowed to do that 
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "TheChickenLab :: Cannot be called by a contract");
        _;
    }

    function mint(uint256 _quantity) external payable callerIsUser{
        require(publicSale, "TheChickenLab :: Not Yet Active.");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "TheChickenLab :: Beyond Max Supply");
        require((totalPublicMint[msg.sender] +_quantity) <= MAX_PUBLIC_MINT, "TheChickenLab :: Already minted 1 time!");
        require(msg.value >= (PUBLIC_SALE_PRICE * _quantity), "TheChickenLab :: Below ");

        totalPublicMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    function whitelistMint(bytes32[] memory proof, uint256 _quantity) external payable callerIsUser{
        require(whiteListSale, "TheChickenLab :: Minting is on Pause");
        require((totalSupply() + _quantity) <= MAX_SUPPLY, "TheChickenLab :: Cannot mint beyond max supply");
        require((totalWhitelistMint[msg.sender] + _quantity)  <= MAX_WHITELIST_MINT, "TheChickenLab :: Cannot mint beyond whitelist max mint!");
        require(msg.value >= (WHITELIST_SALE_PRICE * _quantity), "TheChickenLab :: Payment is below the price");
        
        require(isValid(proof, keccak256(abi.encodePacked(msg.sender))), "TheChickenLab :: You are not in Whitelist!");
        totalWhitelistMint[msg.sender] += _quantity;
        _safeMint(msg.sender, _quantity);
    }

    function isValid(bytes32[] memory proof, bytes32 leaf) public view returns (bool){
        return MerkleProof.verify(proof, merkleRoot, leaf);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    //return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 trueId = tokenId + 1;

        if(!isRevealed){
            return placeholderTokenUri;
        }
        //string memory baseURI = _baseURI();
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, trueId.toString(), ".json")) : "";
    }

    function setTokenUri(string memory _baseTokenUri) external onlyOwner{
        baseTokenUri = _baseTokenUri;
    }
    function setPlaceHolderUri(string memory _placeholderTokenUri) external onlyOwner{
        placeholderTokenUri = _placeholderTokenUri;
    }


    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner{
        merkleRoot = _merkleRoot;
    }

    function getMerkleRoot() external view returns (bytes32){
        return merkleRoot;
    }

    function togglePause() external onlyOwner{
        pause = !pause;
    }

    function toggleWhiteListSale() external onlyOwner{
        whiteListSale = !whiteListSale;
    }

    function togglePublicSale() external onlyOwner{
        publicSale = !publicSale;
    }

    function toggleReveal() external onlyOwner{
        isRevealed = !isRevealed;
    }

    function withdraw() external onlyOwner{
        uint256 withdrawAmount = address(this).balance;
        payable(0x6f8cD15140514Fedcf030494573eAAa393f22d5d).transfer(withdrawAmount);
        payable(msg.sender).transfer(address(this).balance);
    }
}