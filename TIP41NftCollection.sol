pragma ton-solidity = 0.58.1;

pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import './ITIP41NftCollection.sol';
import './resolvers/NftResolver.sol';

contract TIP4NftCollection is ITIP41NftCollection {
    
    uint256 _totalSupply;

    constructor(TvmCell codeNft, uint256 ownerPubkey) public {
        
    }

    function totalSupply() external view override responsible returns (uint128 count) {
        return {value: 0, flag: 64} (_totalSupply);
    }

    function nftCode() external view override responsible returns (TvmCell code);
    function nftCodeHash() external view override responsible returns (uint256 codeHash);
    function nftAddress(uint256 id) external view override responsible returns (address nft);

}