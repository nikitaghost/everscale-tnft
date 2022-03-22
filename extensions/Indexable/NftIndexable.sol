pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import 'resolvers/IndexResolver.sol';
import 'interfaces/ITIP43Nft.sol';
import '../../Nft.sol';


contract NftIndexable is Nft, IndexResolver, ITIP43Nft {

    uint128 _indexDeployValue;
    uint128 _indexDestroyValue;

    constructor(
        address owner,
        address sendGasTo,
        uint128 remainOnNft,
        uint128 indexDeployValue,
        uint128 indexDestroyValue,
        TvmCell codeIndex
    ) Nft(
        owner,
        sendGasTo,
        remainOnNft
    ) public {
        require(msg.value >= (_indexDeployValue * 2), NftErrors.value_is_less_than_required);
        tvm.accept();

        _indexDeployValue = indexDeployValue;
        _indexDestroyValue = indexDestroyValue;
        _codeIndex = codeIndex;
        
        _supportedInterfaces[ 
            bytes4(tvm.functionId(IIndexResolver.resolveCodeHashIndex)) ^
            bytes4(tvm.functionId(IIndexResolver.resolveIndex))
        ] = true;
        _supportedInterfaces[ 
            bytes4(tvm.functionId(ITIP43Nft.setIndexDeployValue)) ^
            bytes4(tvm.functionId(ITIP43Nft.setIndexDestroyValue)) ^
            bytes4(tvm.functionId(ITIP43Nft.getIndexDeployValue)) ^
            bytes4(tvm.functionId(ITIP43Nft.getIndexDestroyValue))
        ] = true;

    }

    function changeOwner(
        address newOwner, 
        address sendGasTo, 
        mapping(address => CallbackParams) callbacks
    ) public virtual override onlyManager {
        _destructIndex(sendGasTo);
        super.changeOwner(newOwner, sendGasTo, callbacks);
        _deployIndex();
    }

    function _deployIndex() internal virtual view {
        TvmCell codeIndexOwner = _buildIndexCode(address(0), _owner);
        TvmCell stateIndexOwner = _buildIndexState(codeIndexOwner, address(this));
        new Index{stateInit: stateIndexOwner, value: _indexDeployValue}(_collection);

        TvmCell codeIndexOwnerRoot = _buildIndexCode(_collection, _owner);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: _indexDeployValue}(_collection);
    }

    function _destructIndex(address sendGasTo) internal virtual view {
        address oldIndexOwner = resolveIndex(address(0), address(this), _owner);
        IIndex(oldIndexOwner).destruct{value: _indexDestroyValue}(sendGasTo);
        address oldIndexOwnerRoot = resolveIndex(_collection, address(this), _owner);
        IIndex(oldIndexOwnerRoot).destruct{value: _indexDestroyValue}(sendGasTo);
    }

    function setIndexDeployValue(uint128 indexDeployValue) public override onlyManager {
        tvm.rawReserve(msg.value, 1);
        _indexDeployValue = indexDeployValue;
        msg.sender.transfer({value: 0, flag: 128});
    }

    function setIndexDestroyValue(uint128 indexDestroyValue) public override onlyManager {
        tvm.rawReserve(msg.value, 1);
        _indexDestroyValue = indexDestroyValue;
        msg.sender.transfer({value: 0, flag: 128});
    }

    function getIndexDeployValue() public responsible override returns(uint128) {
        return {value: 0, flag: 64} _indexDeployValue;
    }

    function getIndexDestroyValue() public responsible override returns(uint128) {
        return {value: 0, flag: 64} _indexDestroyValue;
    }

}