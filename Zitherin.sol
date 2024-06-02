// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "../../IDegenEngineTraitManager_V1.sol";

contract Zitherin is Ownable, ERC721A {
    using Strings for uint256;

    enum DegenModes {
        Onchain,
        Hybrid,
        Offchain
    }

    event MintingDisabled(address indexed from);
    event MetadataUpdate(uint256 _tokenId);
    event BaseUriUpdated(address indexed from, string _baseURI);
    event TraitManagerUpdated(address indexed from, address _traitManager);
    event DegenTypeUpdated(address indexed from, DegenModes _degenType);

    DegenModes degenMode;
    IDegenEngineTraitManager_V1 traitManager;
    string baseURI;
    bool mintingEnabled;

    constructor() ERC721A("Zitherin", "ZITH") {
        degenMode = DegenModes.Offchain;
        mintingEnabled = true;
    }

    function disableMinting() external onlyOwner {
        mintingEnabled = false;
        emit MintingDisabled(msg.sender);
    }

    function mint(address to) external payable {
        require(mintingEnabled, "Minting is disabled");
        _mint(to, 1);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_exists(tokenId), "token does not exist");
        if (degenMode == DegenModes.Onchain || degenMode == DegenModes.Hybrid) {
            return traitManager.tokenURI(address(this), uint64(tokenId));
        }

        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function metadataUpdate(uint256 tokenId) external {
        emit MetadataUpdate(tokenId);
    }

    function metadataUpdateCollection() external {
        emit MetadataUpdate(type(uint256).max);
    }

    function updateDegenType(DegenModes _degenType) public onlyOwner {
        degenMode = _degenType;
        emit DegenTypeUpdated(msg.sender, _degenType);
    }

    function updateBaseUri(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
        emit BaseUriUpdated(msg.sender, _baseURI);
    }

    function updateTraitManager(address _newTraitManager) public onlyOwner {
        traitManager = IDegenEngineTraitManager_V1(_newTraitManager);
        emit TraitManagerUpdated(msg.sender, _newTraitManager);
    }
}
