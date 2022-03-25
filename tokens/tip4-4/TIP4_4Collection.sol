pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../tip4-1/TIP4_1Collection.sol';
import './interfaces/ITIP4_4Collection.sol';
import './Storage.sol';
import './TIP4_4Nft.sol';

contract TIP4_4Collection is TIP4_1Collection, ITIP4_4Collection {

    TvmCell _codeStorage;

    /// _remainOnNft - the number of crystals that will remain after the entire mint 
    /// process is completed on the Nft contract
    uint128 _remainOnNft = 0.3 ton;

    /// @dev пересчитать
    uint128 _remainOnStorage = 0.5 ton;         

    constructor(
        TvmCell codeNft, 
        TvmCell codeStorage,
        uint256 ownerPubkey
    ) TIP4_1Collection(
        codeNft, 
        ownerPubkey
    ) public {
        tvm.accept();
        
        _codeStorage = codeStorage;
    }

    /// @param uploader - The address of the contract that will be able to upload chunks to storage
    function mintNft(
        address uploader,
        string mimeType,
        uint128 chunksNum
    ) external virtual {
        require(msg.value > _remainOnNft + _remainOnStorage + 0.1 ton, CollectionErrors.value_is_less_than_required);
        tvm.rawReserve(msg.value, 1);

        address storageAddr = _deployStorage(uploader, mimeType, chunksNum);
        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, uint256(_totalSupply));
        address nftAddr = new TIP4_4Nft{
            stateInit: stateNft,
            value: msg.value
        }(
            msg.sender,
            msg.sender,
            _remainOnNft,
            storageAddr
        ); 

        emit NftCreated(
            _totalSupply, 
            nftAddr,
            msg.sender,
            msg.sender, 
            msg.sender
        );

        _totalSupply++;

        msg.sender.transfer({value: 0, flag: 128});
    }

    function storageCode() external override view responsible returns (TvmCell code) {

    }

    function storageCodeHash() external override view responsible returns (uint256 codeHash) {

    }

    function resolveStorage(address nft) external override view responsible returns (address storage) {

    }


    function _deployStorage(
        address uploader,
        string mimeType,
        uint128 chunksNum
    ) internal virtual returns(address newStorage) {
        address nft = resolveNft(address(this), _totalSupply);
        newStorage = new Storage{
            code : _codeStorage,
            value : _remainOnStorage,
            varInit : {
                _nft : nft
            }
        }(
            uploader,
            address(this),
            mimeType,
            chunksNum
        );
    }

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal virtual override pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: TIP4_4Nft,
            varInit: {_id: id},
            code: code
        });
    }

}