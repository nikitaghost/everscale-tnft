// ItGold.io Contracts (v1.0.0) 

pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import './interfaces/ITIP41Nft.sol';
import './interfaces/INftChangeOwner.sol';
import './interfaces/INftChangeManager.sol';

import './errors/NftErrors.sol';

import './utils/TIP6/TIP6.sol';

/// @title One of the required contracts of an TIP4-1(Non-Fungible Token Standard) compliant technology.
/// For detect what interfaces a smart contract implements used TIP-6.1 standard. ...
/// ... Read more here (https://github.com/nftalliance/docs/blob/main/src/Standard/TIP-6/1.md)
contract Nft is ITIP41Nft, TIP6 {

    /// Unique NFT id
    uint256 static _id;

    /// Address of NftCollection contract
    address _collection;

    /// Owner address
    address _owner;

    /// Manager address. Used in onlyManager modifier.
    address _manager;

    /**
        @notice Initializes the contract by setting a `owner` to the NFT.
        Collection address get from the contract code that is "building" into Collection._buildNftCode, Collection._buildNftState
        _supportedInterfaces mapping used in TIP-6 standart
        Emit TokenMinted event
    */
    constructor(
        address owner,
        address sendGasTo,
        uint128 remainOnNft
    ) public {

        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), NftErrors.value_is_empty);
        (address collection) = optSalt.get().toSlice().decode(address);
        require(msg.sender == collection, NftErrors.sender_is_not_collection);
        require(remainOnNft != 0, NftErrors.value_is_empty);
        require(msg.value > remainOnNft, NftErrors.value_is_less_than_required);
        tvm.accept();
        tvm.rawReserve(0, remainOnNft);

        _collection = collection;
        _owner = owner;
        _manager = owner;

        _supportedInterfaces[ bytes4(tvm.functionId(ITIP6.supportsInterface)) ] = true;
        _supportedInterfaces[
            bytes4(tvm.functionId(ITIP41Nft.getInfo)) ^
            bytes4(tvm.functionId(ITIP41Nft.changeOwner)) ^
            bytes4(tvm.functionId(ITIP41Nft.changeManager))
        ] = true;

        emit TokenMinted(_owner, _manager);

        sendGasTo = sendGasTo.value == 0 ? msg.sender : sendGasTo;
        sendGasTo.transfer({value: 0, flag: 128});
    }
     
    /// @notice Transfers ownership to another account
    /// @param newOwner - the future owner of the token
    /// @param sendGasTo - the address to which the remaining gas will be sent
    /// @param callbacks - key (destination address for callback) => ..
    /// .. value (CallbackParams structure ( CallbackParams { uint128 value; TvmCell payload; } ))
    /// Can only be called from the manager's address
    /// Requirements:
    ///
    /// - `newOwner` cannot be the zero address.
    /// - `sendGasTo` can be the zero address.
    /// - `callbacks` can be the zero mapping.
    /// - Callbacks(key) address must implement {INftChangeOwner-onNftChangeOwner}.
    ///
    /// Emits a {OwnerChanged} event.
    function changeOwner(
        address newOwner, 
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) external virtual override onlyManager {

        require(newOwner.value != 0, NftErrors.value_is_empty);
        tvm.rawReserve(msg.value, 1);

        address oldOwner = _owner;
        sendGasTo = sendGasTo.value != 0 ? sendGasTo : msg.sender;

        _changeOwner(newOwner);
        emit OwnerChanged(oldOwner, newOwner);

        optional(TvmCell) callbackToGasOwner;
        for ((address dest, CallbackParams p) : callbacks) {
            if (dest.value != 0) {
                if (sendGasTo != dest) {
                    INftChangeOwner(dest).onNftChangeOwner{
                        value: p.value,
                        flag: 0,
                        bounce: false
                    }(_id, oldOwner, _manager, newOwner, _manager, _collection, sendGasTo, p.payload);
                } else {
                    callbackToGasOwner.set(p.payload);
                }
            }
        }

        if (sendGasTo.value != 0) {
            if (callbackToGasOwner.hasValue()) {
                INftChangeOwner(sendGasTo).onNftChangeOwner{
                    value: 0,
                    flag: 128,
                    bounce: false
                }(_id, oldOwner, _manager, newOwner, _manager, _collection, sendGasTo, callbackToGasOwner.get());
            } else {
                sendGasTo.transfer({
                    value: 0,
                    flag: 128,
                    bounce: false
                });
            }
        }

    }   

    function _changeOwner(
        address newOwner
    ) internal {
        require(newOwner.value != 0, NftErrors.value_is_empty);

        _owner = newOwner;
    }


    /// @notice Set a new manager
    /// @param newManager - future manager of the token
    /// @param sendGasTo - the address to which the remaining gas will be sent
    /// @param callbacks - key (destination address for callback) => ..
    /// .. value (CallbackParams structure ( CallbackParams { uint128 value; TvmCell payload; } ))
    /// Can only be called from the manager's address
    /// Requirements:
    ///
    /// - `newManager` cannot be the zero address.
    /// - `sendGasTo` can be the zero address.
    /// - `callbacks` can be the zero mapping.
    /// - Callbacks(key) address must implement {INftChangeManager-onNftChangeManager}.
    ///
    /// Emits a {ManagerChanged} event.
    function changeManager(
        address newManager, 
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) external virtual override onlyManager {

        require(newManager.value != 0, NftErrors.value_is_empty);
        tvm.rawReserve(msg.value, 1);

        address oldManager = _manager;
        sendGasTo = sendGasTo.value != 0 ? sendGasTo : msg.sender;

        _changeManager(newManager);
        emit ManagerChanged(oldManager, newManager);

        optional(TvmCell) callbackToGasOwner;
        for ((address dest, CallbackParams p) : callbacks) {
            if (dest.value != 0) {
                if (sendGasTo != dest) {
                    INftChangeManager(dest).onNftChangeManager{
                        value: p.value,
                        flag: 0,
                        bounce: false
                    }(_id, _owner, oldManager, _owner, newManager, _collection, sendGasTo, p.payload);
                } else {
                    callbackToGasOwner.set(p.payload);
                }
            }
        }

        if (sendGasTo.value != 0) {
            if (callbackToGasOwner.hasValue()) {
                INftChangeManager(sendGasTo).onNftChangeManager{
                    value: 0,
                    flag: 128,
                    bounce: false
                }(_id, _owner, oldManager, _owner, newManager, _collection, sendGasTo, callbackToGasOwner.get());
            } else {
                sendGasTo.transfer({
                    value: 0,
                    flag: 128,
                    bounce: false
                });
            }
        }

    }

    function _changeManager(
        address newManager
    ) internal {
        require(newManager.value != 0, NftErrors.value_is_empty);

        _manager = newManager;
    }

    /// @notice Returns the main parameters of the token.
    /// @return id - Unique NFT id
    /// @return owner - Nft owner
    /// @return manager - Nft manager (Used for contract management)
    /// @return collection - Collection address (creator)
    ///
    /// Both internal message and external message can be called. 
    /// In case of calling external message, you need to add the answerId = 0 parameter
    function getInfo() external view virtual override responsible returns(
        uint256 id, 
        address owner, 
        address manager, 
        address collection)
    {
        return {value: 0, flag: 64} (
            _id,
            _owner,
            _manager,
            _collection
        );
    }

    modifier onlyManager virtual {
        require(msg.sender == _manager, NftErrors.sender_is_not_manager);
        _;
    }
}