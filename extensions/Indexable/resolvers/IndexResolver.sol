pragma ton-solidity >= 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;

import '../Index.sol';
import './IIndexResolver.sol';

// TODO: Test the hypothesis that inline will be more profitable in a given situation

contract IndexResolver is IIndexResolver {
    TvmCell _codeIndex;

    function resolveCodeHashIndex(
        address collection,
        address owner
    ) public view responsible override returns (uint256 codeHashIndex) {
        return {value: 0, flag: 64} tvm.hash(_buildIndexCode(collection, owner));
    }

    function resolveIndex(
        address collection,
        address nft,
        address owner
    ) public view responsible override returns (address index) {
        TvmCell code = _buildIndexCode(collection, owner);
        TvmCell state = _buildIndexState(code, nft);
        uint256 hashState = tvm.hash(state);
        index = address.makeAddrStd(0, hashState);
        return {value: 0, flag: 64} index;
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
}