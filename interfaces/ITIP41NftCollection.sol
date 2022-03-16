pragma ton-solidity = 0.58.1;

interface ITIP41NftCollection {
    function totalSupply() external view responsible returns (uint128 count);
    function nftCode() external view responsible returns (TvmCell code);
    function nftCodeHash() external view responsible returns (uint256 codeHash);
    function nftAddress(uint256 id) external view responsible returns (address nft);
    event Test();
}