pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import 'resolvers/IndexResolver.sol';
import 'interfaces/ITIP43NftCollection.sol';
import '../../Collection.sol';
import './NftIndexable.sol';

/// @dev add IndexBasis
contract CollectionIndexable is Collection, IndexResolver, ITIP43NftCollection {

    address _addrIndexBasis;

    uint128 _indexDeployValue = 0.4 ton;
    uint128 _indexDestroyValue = 0.4 ton;
    uint128 _deployIndexBasisValue = 0.4 ton;

    constructor(
        TvmCell codeNft,
        TvmCell codeIndex,
        uint256 ownerPubkey
    ) Collection(
        codeNft,
        ownerPubkey
    ) public {
        TvmCell empty;
        require(codeIndex != empty, CollectionErrors.value_is_empty);
        tvm.accept();

        _codeIndex = codeIndex;
    }

    function mintNft() external override {
        require(msg.value > (_indexDeployValue * 2) + _remainOnNft, CollectionErrors.value_is_less_than_required);
        require(msg.value > _remainOnNft + 0.1 ton, CollectionErrors.value_is_less_than_required);
        tvm.rawReserve(msg.value, 1);

        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, _totalSupply);
        address nftAddr = new NftIndexable{
            stateInit: stateNft,
            value: msg.value
        }(
            msg.sender,
            msg.sender,
            _remainOnNft,
            _indexDeployValue,
            _indexDestroyValue,
            _codeIndex
        ); 

        emit nftCreated(
            _totalSupply, 
            nftAddr,
            msg.sender,
            msg.sender, 
            msg.sender
        );

        _totalSupply++;

        msg.sender.transfer({value: 0, flag: 128});
    }

    function setIndexDeployValue(uint128 indexDeployValue) external virtual override onlyOwner {
        _indexDeployValue = indexDeployValue;
    }

    function setIndexDestroyValue(uint128 indexDestroyValue) external virtual override onlyOwner {
        _indexDestroyValue = indexDestroyValue;
    }

    function getIndexDeployValue() public view responsible override returns(uint128) {
        return {value: 0, flag: 64} _indexDeployValue;
    }

    function getIndexDestroyValue() public view responsible override returns(uint128) {
        return {value: 0, flag: 64} _indexDestroyValue;
    }

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal override pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: NftIndexable,
            varInit: {_id: id},
            code: code
        });
    }

}