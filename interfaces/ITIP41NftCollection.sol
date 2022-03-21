pragma ton-solidity = 0.58.1;

interface ITIP41NftCollection {

    /// @notice This event emits when NFTs are created(minted)
    /// @param id Unique NFT id
    /// @param nft Address of nft contract
    /// @param owner Address of nft owner
    /// @param manager Address of nft manager
    /// @param creator Address of creator that initialize mint nft
    event nftCreated(
        uint256 id, 
        address nft, 
        address owner, 
        address manager, 
        address creator
    );

    /// @notice This event emits when NFTs are burned
    /// @param id Unique NFT id
    /// @param nft Address of nft contract
    /// @param owner Address of nft owner when it burned
    /// @param manager Address of nft manager when in burned
    event nftBurned(
        uint256 id,
        address nft,
        address owner,
        address manager
    );

    /// @notice Count active NFTs for this collection
    /// @return count A count of active NFTs minted by this contract except for burned NFTs 
    function totalSupply() external view responsible returns (uint256 count);

    /// @notice Returns the NFT code 
    /// @return code NFT code as TvmCell
    function nftCode() external view responsible returns (TvmCell code);

    /// @notice Returns the NFT code hash
    /// @return codeHash NFT code hash
    function nftCodeHash() external view responsible returns (uint256 codeHash);

    /// @notice Computes NFT address by unique NFT id
    /// @dev Return unique address for all Ids. You find nothing by address for not a valid NFT
    /// @param id Unique NFT id
    /// @return nft Returns address of NFT contract
    function nftAddress(uint256 id) external view responsible returns (address nft);

    function mintNft() external;

    function withdraw(address to, uint128 value) external pure;
    
    function setRemainOnNft(uint128 remainOnNft) external;
       
    function resolveCodeHashNft() external view responsible returns (uint256 codeHashData);

    function resolveNft(
        address addrRoot,
        uint256 id
    ) external view responsible returns (address addrNft);


}