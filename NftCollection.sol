pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import './ITIP41NftCollection.sol';
import './Nft.sol';

/// @dev добавить методы resolver в интерфейс
contract NftCollection is ITIP41NftCollection {
    
    TvmCell _codeNft;
    uint256 _totalSupply;

    constructor(TvmCell codeNft, uint256 ownerPubkey) public {
        tvm.accept();

        _codeNft = codeNft;
        _totalSupply = 0;
    }

    function totalSupply() external view virtual override responsible returns (uint128 count) {
        return {value: 0, flag: 64} (_totalSupply);
    }

    function nftCode() external view virtual override responsible returns (TvmCell code);
    function nftCodeHash() external view virtual override responsible returns (uint256 codeHash);
    function nftAddress(uint256 id) external view virtual override responsible returns (address nft);

    function resolveCodeHashNft() public view returns (uint256 codeHashData) {
        return tvm.hash(_buildNftCode(address(this)));
    }

    function resolveNft(
        address addrRoot,
        uint256 id
    ) public view returns (address addrNft) {
        TvmCell code = _buildNftCode(addrRoot);
        TvmCell state = _buildNftState(code, id);
        uint256 hashState = tvm.hash(state);
        addrNft = address.makeAddrStd(0, hashState);
    }

    function _buildNftCode(address addrRoot) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(addrRoot);
        return tvm.setCodeSalt(_codeNft, salt.toCell());
    }

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Nft,
            varInit: {_id: id},
            code: code
        });
    }

}