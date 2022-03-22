pragma ton-solidity >= 0.58.1;

interface IIndexResolver {
    function resolveCodeHashIndex(
        address collection,
        address owner
    ) external view responsible returns (uint256 codeHashIndex);
    function resolveIndex(
        address collection,
        address nft,
        address owner
    ) external view responsible returns (address index);
}