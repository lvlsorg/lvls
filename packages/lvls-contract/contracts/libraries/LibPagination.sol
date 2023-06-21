pragma solidity ^0.8.0;

error ExceededOffsetLimit(uint256 limit);

library LibPagination {
    function paginateData(
        address[] memory collection,
        uint256 offset,
        uint256 limit,
        bool asc
    )
        internal
        pure
        returns (
            address[] memory,
            uint256,
            uint256
        )
    {
        uint256 length = collection.length;
        uint256 total = length;
        uint256 count = 0;
        unchecked {
            if (offset > length) {
                revert ExceededOffsetLimit(length);
            }
            if (offset + limit > length) {
                limit = length - offset;
            }
            address[] memory result = new address[](limit);
            if (asc) {
                for (uint256 i = 0; i < limit; i++) {
                    count = count + 1;
                    result[i] = collection[offset + i];
                }
            } else {
                for (uint256 i = 0; i < limit; i++) {
                    count = count + 1;
                    result[i] = collection[length - offset - i - 1];
                }
            }
            return (result, count, total);
        }
    }
}
