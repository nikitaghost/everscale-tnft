pragma ton-solidity = 0.58.1;

import '../structures/ICallbackParamsStructure.sol';

/// @title One of the required interfaces of an TIP4-1 compliant contract. Required for "Nft" contract.
interface ITIP41Nft is ICallbackParamsStructure {

    /// @notice Returns the main parameters of the token.
    /// @return id - Unique NFT id
    /// @return owner - Nft owner
    /// @return manager - Nft manager (Used for contract management)
    /// @return collection - Collection address (creator)
    function getInfo() external view responsible returns(uint256 id, address owner, address manager, address collection);

    /// @notice Transfers ownership to another account
    /// Can only be called from the manager's address
    /// @param newOwner - the future owner of the token
    /// @param sendGasTo - the address to which the remaining gas will be sent
    /// @param callbacks - key (destination address for callback) => ..
    /// .. value (CallbackParams structure ( CallbackParams { uint128 value; TvmCell payload; } ))
    function changeOwner(address newOwner, address sendGasTo, mapping(address => CallbackParams) callbacks) external;

    /// @notice Set a new manager
    /// Can only be called from the manager's address
    /// @param newManager - future manager of the token
    /// @param sendGasTo - the address to which the remaining gas will be sent
    /// @param callbacks - key (destination address for callback) => ..
    /// .. value (CallbackParams structure ( CallbackParams { uint128 value; TvmCell payload; } ))
    function changeManager(address newManager, address sendGasTo, mapping(address => CallbackParams) callbacks) external;

    /// @notice This event emit when NFT is created
    /// @param owner - address of nft owner
    /// @param manager - address of nft manager
    event TokenMinted(address owner, address manager);
    
    /// @notice This event emit when NFT owner is changed
    /// @param oldOwner - current owner of the token
    /// @param newOwner - future owner of the token
    event OwnerChanged(address oldOwner, address newOwner);

    /// @notice This event emit when NFT manager is changed
    /// @param oldManager - current manager of the token
    /// @param newManager - the future manager of the token
    event ManagerChanged(address oldManager, address newManager);

    /// @notice This event emit when NFT is destroyed
    /// @param owner - address of nft owner
    /// @param manager - address of nft manager
    event TokenBurned(address owner, address manager);

}
