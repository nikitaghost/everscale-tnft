pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../tip4-1/TIP4_1Collection.sol';
import './interfaces/ITIP4_3Collection.sol';
import './TIP4_3Nft.sol';
import './Index.sol';
import './IndexBasis.sol';


contract TIP4_3Collection is TIP4_1Collection, ITIP4_3Collection {
    
    TvmCell _codeIndex;
    TvmCell _codeIndexBasis;

    uint128 _indexDeployValue = 0.4 ton;
    uint128 _indexDestroyValue = 0.4 ton;
    uint128 _deployIndexBasisValue = 0.4 ton;

    /// _remainOnNft - the number of crystals that will remain after the entire mint 
    /// process is completed on the Nft contract
    // uint128 _remainOnNft = 0.3 ton;

    constructor(
        TvmCell codeNft, 
        TvmCell codeIndex,
        TvmCell codeIndexBasis,
        uint256 ownerPubkey
    ) TIP4_1Collection(
        codeNft, 
        ownerPubkey
    ) public {
        TvmCell empty;
        require(codeIndex != empty, CollectionErrors.value_is_empty);
        tvm.accept();

        _codeIndex = codeIndex;
        _codeIndexBasis = codeIndexBasis;
    }

    // function mintNft() external virtual {
    //     require(msg.value > (_indexDeployValue * 2) + _remainOnNft, CollectionErrors.value_is_less_than_required);
    //     tvm.rawReserve(msg.value, 1);

    //     TvmCell codeNft = _buildNftCode(address(this));
    //     TvmCell stateNft = _buildNftState(codeNft, _totalSupply);
    //     address nftAddr = new TIP4_3Nft{
    //         stateInit: stateNft,
    //         value: msg.value
    //     }(
    //         msg.sender,
    //         msg.sender,
    //         _remainOnNft,
    //         _indexDeployValue,
    //         _indexDestroyValue,
    //         _codeIndex
    //     ); 

    //     emit NftCreated(
    //         _totalSupply, 
    //         nftAddr,
    //         msg.sender,
    //         msg.sender, 
    //         msg.sender
    //     );

    //     _totalSupply++;

    //     msg.sender.transfer({value: 0, flag: 128});
    // }

    function deployIndexBasis(uint128 value) external view responsible onlyOwner returns (address indexBasis) {
        TvmCell empty;
        require(_codeIndexBasis != empty, CollectionErrors.value_is_empty);

        TvmCell code = _buildIndexBasisCode();
        TvmCell state = _buildIndexBasisState(code, address(this));
        indexBasis = new IndexBasis{stateInit: state, value: value}();
        return {value: 0, flag: 64} (indexBasis);
    }

    function setIndexBasisCode(TvmCell codeIndexBasis) external virtual onlyOwner {
        _codeIndexBasis = codeIndexBasis;
    }

    // function setRemainOnNft(uint128 remainOnNft) external virtual onlyOwner {
    //     _remainOnNft = remainOnNft;
    // } 

    function indexBasisCode() external view override responsible returns (TvmCell code) {
        return {value: 0, flag: 64} (_codeIndexBasis);
    }   

    function indexBasisCodeHash() external view override responsible returns (uint256 hash) {
        return {value: 0, flag: 64} tvm.hash(_buildIndexBasisCode());
    }

    function resolveIndexBasis() external view override responsible returns (address indexBasis) {
        TvmCell code = _buildIndexBasisCode();
        TvmCell state = _buildIndexBasisState(code, address(this));
        uint256 hashState = tvm.hash(state);
        indexBasis = address.makeAddrStd(0, hashState);
        return {value: 0, flag: 64} indexBasis;
    }

    function _buildIndexBasisCode() internal virtual view returns (TvmCell) {
        string stamp = "nft";
        TvmBuilder salt;
        salt.store(stamp);
        return tvm.setCodeSalt(_codeIndexBasis, salt.toCell());
    }

    function _buildIndexBasisState(
        TvmCell code,
        address collection
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: IndexBasis,
            varInit: {_collection: collection},
            code: code
        });
    }

    function indexCode() external view override responsible returns (TvmCell code) {
        return {value: 0, flag: 64} (_codeIndex);
    }

    function indexCodeHash(address owner) external view override responsible returns (uint256 hash) {
        return {value: 0, flag: 64} tvm.hash(_buildIndexCode(address(this), owner));
    }

    function _buildIndexCode(
        address collection,
        address owner
    ) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(collection);
        salt.store(owner);
        return tvm.setCodeSalt(_codeIndex, salt.toCell());
    }

    function _buildIndexState(
        TvmCell code,
        address nft
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Index,
            varInit: {_nft: nft},
            code: code
        });
    }

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal virtual override pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: TIP4_3Nft,
            varInit: {_id: id},
            code: code
        });
    }



}