// ItGold.io Contracts (v1.0.0) 

pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;


import '../tokens/tip4-2/TIP4_2Nft.sol';

contract Nft is TIP4_2Nft {

    string _name;

    constructor(
        address owner,
        address sendGasTo,
        uint128 remainOnNft,
        string json,
        string name,
        uint128 indexDeployValue,
        uint128 indexDestroyValue,
        TvmCell codeIndex
    ) TIP4_2Nft (
        owner,
        sendGasTo,
        remainOnNft,
        json
    ) public {
        tvm.accept();

        _name = name;

    }
    
    function getName() external view responsible returns (string name) {
        return {value: 0, flag: 64} (_name);
    }

}