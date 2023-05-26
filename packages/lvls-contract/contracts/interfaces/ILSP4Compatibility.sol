// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// interfaces
/**
 * @dev LSP4 extension, for compatibility with clients & tools that expect ERC20/721.
 */
interface ILSP4Compatibility {
    /**
     * @dev Returns the name of the token.
     * @return The name of the token
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name.
     * @return The symbol of the token
     */
    function symbol() external view returns (string memory);
}
