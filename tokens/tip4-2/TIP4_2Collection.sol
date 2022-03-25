pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../tip4-1/TIP4_1Collection.sol';
import './interfaces/ITIP4_2JSON_Metadata.sol';
import './TIP4_2Nft.sol';

/// The contract is the same as tip4-1, but with an added variable in mint for nft (string json)
/// add change deploy contract in mint & _buildNftState (TIP4_1Nft => TIP4_2Nft)
contract TIP4_2Collection is TIP4_1Collection, ITIP4_2JSON_Metadata {

    /// _remainOnNft - the number of crystals that will remain after the entire mint 
    /// process is completed on the Nft contract
    // uint128 _remainOnNft = 0.3 ton;

    string _json;

    constructor(
        TvmCell codeNft, 
        uint256 ownerPubkey,
        string json
    ) TIP4_1Collection(
        codeNft, 
        ownerPubkey
    ) public {
        tvm.accept();

        _json = json;
    }

    /// See interfaces/ITIP4_2JSON_Metadata.sol
    function getJson() external view override responsible returns (string json) {
        return {value: 0, flag: 64, bounce: false} (_json);
    }

    function _buildNftState(
        TvmCell code,
        uint256 id
    ) internal virtual override pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: TIP4_2Nft,
            varInit: {_id: id},
            code: code
        });
    }

    // function mintNft(string json) external virtual {
    //     require(msg.value > _remainOnNft + 0.1 ton, CollectionErrors.value_is_less_than_required);
    //     tvm.rawReserve(msg.value, 1);

    //     TvmCell codeNft = _buildNftCode(address(this));
    //     TvmCell stateNft = _buildNftState(codeNft, uint256(_totalSupply));
    //     address nftAddr = new TIP4_2Nft{
    //         stateInit: stateNft,
    //         value: msg.value
    //     }(
    //         msg.sender,
    //         msg.sender,
    //         _remainOnNft,
    //         json
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

    // function setRemainOnNft(uint128 remainOnNft) external virtual onlyOwner {
    //     _remainOnNft = remainOnNft;
    // } 

}