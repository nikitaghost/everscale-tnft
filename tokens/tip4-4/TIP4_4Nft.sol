// ItGold.io Contracts (v1.0.0) 

pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../tip4-1/TIP4_1Nft.sol';
import './interfaces/ITIP4_4NFT.sol';


contract TIP4_4Nft is TIP4_1Nft, ITIP4_4NFT {

    address _storage;
    bool _active;

    constructor(
        address owner,
        address sendGasTo,
        uint128 remainOnNft,
        address storageAddr
    ) TIP4_1Nft (
        owner,
        sendGasTo,
        remainOnNft
    ) public {
        tvm.accept();

        _storage = storageAddr;

        _supportedInterfaces[
            bytes4(tvm.functionId(ITIP4_4NFT.onStorageFillComplete)) ^
            bytes4(tvm.functionId(ITIP4_4NFT.getStorage))
        ] = true;

    }
    
    function onStorageFillComplete(address gasReceiver) external override {
        require(msg.sender == _storage);
        tvm.rawReserve(0, msg.value);

        _active = true;

        gasReceiver.transfer({value: 0, flag: 128});
    }

    function getStorage() external view override responsible returns (address addr) {
        return {value: 0, flag: 64} (_storage);
    }

    modifier onlyManager virtual override {
        require(msg.sender == _manager, NftErrors.sender_is_not_manager);
        require(_active);
        _;
    }

}