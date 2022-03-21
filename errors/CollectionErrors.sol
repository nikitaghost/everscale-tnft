pragma ton-solidity = 0.58.1;

/**
    Reserved codes - 100-149
 */
library CollectionErrors {
    uint8 constant sender_is_not_owner = 100;
    uint8 constant value_is_greater_than_the_balance = 101;
}