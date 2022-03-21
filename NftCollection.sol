pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import 'interfaces/ITIP41NftCollection.sol';
import './extensions/CollectionExtensions/OwnableExternal.sol';
import './errors/CollectionErrors.sol';
import './Nft.sol';

contract NftCollection is ITIP41NftCollection, OwnableExternal {
    
    TvmCell _codeNft;
    uint256 _totalSupply;

    /// _remainOnNft - the number of crystals that will remain after the entire mint 
    /// process is completed on the Nft contract
    uint128 _remainOnNft = 0.3 ton;

    constructor(TvmCell codeNft, uint256 ownerPubkey) OwnableExternal(ownerPubkey) public {
        tvm.accept();

        _codeNft = codeNft;
        _totalSupply = 0;
    }

    function mintNft() external virtual override {
        tvm.rawReserve(msg.value, 1);

        TvmCell codeNft = _buildNftCode(address(this));
        TvmCell stateNft = _buildNftState(codeNft, _totalSupply);
        address nftAddr = new Nft{
            stateInit: stateNft,
            value: _remainOnNft
        }(msg.sender); 

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

    function withdraw(address to, uint128 value) external virtual override pure onlyOwner {
        require(address(this).balance > value, CollectionErrors.value_is_greater_than_the_balance);
        to.transfer(value, true, 0);
    }

    function setRemainOnNft(uint128 remainOnNft) external virtual override onlyOwner {
        _remainOnNft = remainOnNft;
    } 

    function totalSupply() external view virtual override responsible returns (uint256 count) {
        return {value: 0, flag: 64} (_totalSupply);
    }

    function nftCode() external view virtual override responsible returns (TvmCell code) {
        return {value: 0, flag: 64} (_buildNftCode(address(this)));
    }

    function nftCodeHash() external view virtual override responsible returns (uint256 codeHash) {
        return {value: 0, flag: 64} (resolveCodeHashNft());
    }

    function nftAddress(uint256 id) external view virtual override responsible returns (address nft) {
        return {value: 0, flag: 64} (resolveNft(address(this), id));
    }

    function resolveCodeHashNft() public view override responsible returns (uint256 codeHashData) {
        return {value: 0, flag: 64}(tvm.hash(_buildNftCode(address(this))));
    }

    function resolveNft(
        address addrRoot,
        uint256 id
    ) public view override responsible returns (address addrNft) {
        TvmCell code = _buildNftCode(addrRoot);
        TvmCell state = _buildNftState(code, id);
        uint256 hashState = tvm.hash(state);
        addrNft = address.makeAddrStd(0, hashState);
        return {value: 0, flag: 64} (addrNft);
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