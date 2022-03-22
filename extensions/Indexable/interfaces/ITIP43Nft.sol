pragma ton-solidity >= 0.58.1;

interface ITIP43Nft {
    function setIndexDeployValue(uint128 indexDeployValue) external;
    function setIndexDestroyValue(uint128 indexDestroyValue) external;
    function getIndexDeployValue() external responsible returns(uint128);
    function getIndexDestroyValue() external responsible returns(uint128);
}