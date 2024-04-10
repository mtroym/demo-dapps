//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.23;

import "./base/UniversalChanIbcApp.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';

contract PolymerERC721UC is UniversalChanIbcApp, ERC721, ERC721Enumerable, ERC721Burnable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    // uint256 public currentTokenId = 0;
    IERC20 public acceptTokenAddress;
    uint256 public randomizerPrice = 1 * 10 ** 18;
    string baseURI;

    event MintAckReceived(address receiver, uint256 tokenId, string message);
    event NFTAckReceived(address voter, address recipient, uint256 voteId);

    enum NFTType {
        POLY1,
        POLY2,
        POLY3,
        POLY4
    }

    mapping(uint256 => NFTType) public tokenTypeMap;
    mapping(NFTType => string) public tokenURIs;
    mapping(NFTType => uint256[]) public typeTokenMap;
    mapping(NFTType => uint256) public typeTokenPriceMap;
    mapping(address => uint256[]) public addressOwnerTokens;

    constructor(
        address _middleware,
        address _feeTokenAddress
    )
        UniversalChanIbcApp(_middleware)
        ERC721("xNFT[CrossChainNFTwithPts]@mtroym", "ptNFT")
    {
        tokenURIs[
            NFTType.POLY1
        ] = "https://emerald-uncertain-cattle-112.mypinata.cloud/ipfs/QmZu7WiiKyytxwwKSwr6iPT1wqCRdgpqQNhoKUyn1CkMD3";
        tokenURIs[
            NFTType.POLY2
        ] = "https://emerald-uncertain-cattle-112.mypinata.cloud/ipfs/QmZu7WiiKyytxwwKSwr6iPT1wqCRdgpqQNhoKUyn1CkMD3";
        tokenURIs[
            NFTType.POLY3
        ] = "https://emerald-uncertain-cattle-112.mypinata.cloud/ipfs/QmZu7WiiKyytxwwKSwr6iPT1wqCRdgpqQNhoKUyn1CkMD3";
        tokenURIs[
            NFTType.POLY4
        ] = "https://emerald-uncertain-cattle-112.mypinata.cloud/ipfs/QmZu7WiiKyytxwwKSwr6iPT1wqCRdgpqQNhoKUyn1CkMD3";

        setAcceptTokenAddress(_feeTokenAddress);
        baseURI = "https://emerald-uncertain-cattle-112.mypinata.cloud/ipfs/QmZu7WiiKyytxwwKSwr6iPT1wqCRdgpqQNhoKUyn1CkMD3";
        // uint256 feeDecimals = acceptTokenAddress.decimals();
        typeTokenPriceMap[NFTType.POLY1] = 10 * 10 ** 18;
        typeTokenPriceMap[NFTType.POLY2] = 50 * 10 ** 18;
        typeTokenPriceMap[NFTType.POLY3] = 150 * 10 ** 18;
        typeTokenPriceMap[NFTType.POLY4] = 500 * 10 ** 18;

        mint(msg.sender, NFTType.POLY4);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "token id does not exist!");
        return tokenURIs[tokenTypeMap[tokenId]];
    }

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://emerald-uncertain-cattle-112.mypinata.cloud/ipfs/QmZu7WiiKyytxwwKSwr6iPT1wqCRdgpqQNhoKUyn1CkMD3";
    }

    function setAcceptTokenAddress(address _erc20TokenAddress) public {
        require(
            msg.sender == owner(),
            "only owner can change fee token address!"
        );
        acceptTokenAddress = IERC20(_erc20TokenAddress);
    }

    function mintNFT1(address recipient) public {
        purchaseMint(recipient, NFTType.POLY1);
    }

    function mintNFT2(address recipient) public {
        purchaseMint(recipient, NFTType.POLY2);
    }

    function mintNFT3(address recipient) public {
        purchaseMint(recipient, NFTType.POLY3);
    }

    function mintNFT4(address recipient) public {
        purchaseMint(recipient, NFTType.POLY4);
    }

    function purchaseMint(address recipient, NFTType ptype) internal {
        require(msg.sender == recipient, "you need to mint yourself!");

        uint256 tokenPrice = typeTokenPriceMap[ptype];
        require(
            acceptTokenAddress.balanceOf(recipient) >= tokenPrice,
            "pts to low to mint a nft with pts."
        );
        // acceptTokenAddress.approve(address(this), tokenPrice);
        acceptTokenAddress.transferFrom(msg.sender, address(this), tokenPrice);

        mint(recipient, ptype);
    }

    function getUserOwnedTokens(
        address user
    ) public view virtual returns (uint256[] memory) {
        return addressOwnerTokens[user];
    }

    function tokenVariants(
        uint256 tokenId
    ) public view virtual returns (NFTType) {
        return tokenTypeMap[tokenId];
    }

    function mint(address recipient, NFTType pType) internal returns (uint256) {
        currentTokenId.increment();
        uint256 tokenId = currentTokenId.current();
        tokenTypeMap[tokenId] = pType;
        typeTokenMap[pType].push(tokenId);
        _safeMint(recipient, tokenId);
        _setTokenURI(tokenId, tokenURIs[pType]);
        return tokenId;
    }
    
    function updateTokenURI(string memory _newBaseURI) public {
        baseURI = _newBaseURI;
    }

    // function burn(address sender, uint256 tokenId) internal {
    //     require(_exists(tokenId), "the token id does not exist.");
    //     require(msg.sender == sender, "plz operate burn yourself!");

    // }
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        // require(_exists(tokenId), "the token id does not exist.");
        super._burn(tokenId);
    }

    function randomMint(address recipient) public {
        require(
            acceptTokenAddress.balanceOf(recipient) >= randomizerPrice,
            "pts too low to mint a randomizer!"
        );
        // require()
        // acceptTokenAddress
        acceptTokenAddress.transferFrom(
            recipient,
            address(this),
            randomizerPrice
        );
        uint256 random = uint256(
            keccak256(abi.encodePacked(block.timestamp, recipient))
        ) % 100;
        NFTType pType = NFTType.POLY1;
        if (random >= 50 && random < 75) {
            pType = NFTType.POLY2;
        } else if (random >= 75 && random < 95) {
            pType = NFTType.POLY3;
        } else if (random >= 95) {
            pType = NFTType.POLY4;
        }
        mint(recipient, pType);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721, IERC721) {
        revert("Transfer not allowed");
    }

    function getTokenId() public view returns (uint256) {
        return currentTokenId.current();
    }

    function crossChainMint(
        address destPortAddr,
        bytes32 channelId,
        uint64 timeoutSeconds,
        NFTType tokenType
    ) external {
        bytes memory payload = abi.encode(msg.sender, tokenType);
        uint64 timeoutTimestamp = uint64(
            (block.timestamp + timeoutSeconds) * 1000000000
        );

        // Check if they have enough Polymer Testnet Tokens to mint the NFT
        // If not Revert

        // Burn the Polymer Testnet Tokens from the sender

        IbcUniversalPacketSender(mw).sendUniversalPacket(
            channelId,
            IbcUtils.toBytes32(destPortAddr),
            payload,
            timeoutTimestamp
        );
    }

    /**
     * @dev Packet lifecycle callback that implements packet receipt logic and returns and acknowledgement packet.
     *      MUST be overriden by the inheriting contract.
     *
     * @param channelId the ID of the channel (locally) the packet was received on.
     * @param packet the Universal packet encoded by the source and relayed by the relayer.
     */
    function onRecvUniversalPacket(
        bytes32 channelId,
        UniversalPacket calldata packet
    ) external override onlyIbcMw returns (AckPacket memory ackPacket) {
        recvedPackets.push(UcPacketWithChannel(channelId, packet));

        (address _caller, NFTType tokenType) = abi.decode(
            packet.appData,
            (address, NFTType)
        );

        uint256 tokenId = mint(_caller, tokenType);

        return AckPacket(true, abi.encode(_caller, tokenId));
    }

    /**
     * @dev Packet lifecycle callback that implements packet acknowledgment logic.
     *      MUST be overriden by the inheriting contract.
     *
     * @param channelId the ID of the channel (locally) the ack was received on.
     * @param packet the Universal packet encoded by the source and relayed by the relayer.
     * @param ack the acknowledgment packet encoded by the destination and relayed by the relayer.
     */
    function onUniversalAcknowledgement(
        bytes32 channelId,
        UniversalPacket memory packet,
        AckPacket calldata ack
    ) external override onlyIbcMw {
        ackPackets.push(UcAckWithChannel(channelId, packet, ack));

        // decode the counter from the ack packet
        (address caller, uint256 tokenId) = abi.decode(
            ack.data,
            (address, uint256)
        );

        emit MintAckReceived(caller, tokenId, "NFT minted successfully");
    }

    /**
     * @dev Packet lifecycle callback that implements packet receipt logic and return and acknowledgement packet.
     *      MUST be overriden by the inheriting contract.
     *      NOT SUPPORTED YET
     *
     * @param channelId the ID of the channel (locally) the timeout was submitted on.
     * @param packet the Universal packet encoded by the counterparty and relayed by the relayer
     */
    function onTimeoutUniversalPacket(
        bytes32 channelId,
        UniversalPacket calldata packet
    ) external override onlyIbcMw {
        timeoutPackets.push(UcPacketWithChannel(channelId, packet));
        // do logic
    }
}
