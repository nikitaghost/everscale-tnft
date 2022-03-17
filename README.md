<h1>Ready:</h1>

/errors/NftErrors.sol

/interfaces/INftChangeManager.sol

/interfaces/INftChangeOwner.sol

/interfaces/ITIP41Nft.sol

/structures/ICallbackParamsStructure.sol

/utils/TIP6

./TIP4NFT.sol

tvm.setCodeSalt()
tvm.setCodeSalt(TvmCell code, TvmCell salt) returns (TvmCell newCode);
Inserts salt into code and returns new code newCode.

tvm.buildStateInit()
// 1)
tvm.buildStateInit(TvmCell code, TvmCell data) returns (TvmCell stateInit);
// 2)
tvm.buildStateInit(TvmCell code, TvmCell data, uint8 splitDepth) returns (TvmCell stateInit);
// 3)
tvm.buildStateInit({code: TvmCell code, data: TvmCell data, splitDepth: uint8 splitDepth,
    pubkey: uint256 pubkey, contr: contract Contract, varInit: {VarName0: varValue0, ...}});
Generates a StateInit (TBLKCH - 3.1.7.) from code and data TvmCells. Member splitDepth of the tree of cell StateInit:
