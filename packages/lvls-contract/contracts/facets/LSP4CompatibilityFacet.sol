// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// interfaces
import {ILSP4Compatibility} from "../interfaces/ILSP4Compatibility.sol";

// modules
import {IERC725Y} from "@erc725/smart-contracts/contracts/ERC725YCore.sol";

// constants
import "../libraries/LSP4Constants.sol";

/**
 * @title LSP4Compatibility
 * @author Matthew Stevens
 * @dev LSP4 extension, for compatibility with clients & tools that expect ERC20/721.
 */
contract LSP4CompatibilityFacet is ILSP4Compatibility {
    // --- Token queries

    /**
     * @dev Returns the name of the token.
     * @return The name of the token
     */
    function name() public view virtual override returns (string memory) {
        return string(IERC725Y(address(this)).getData(_LSP4_TOKEN_NAME_KEY));
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name.
     * @return The symbol of the token
     */
    function symbol() public view virtual override returns (string memory) {
        return string(IERC725Y(address(this)).getData(_LSP4_TOKEN_SYMBOL_KEY));
    }

    function setName(string memory name_) public {
        IERC725Y(address(this)).setData(_LSP4_TOKEN_NAME_KEY, bytes(name_));
    }

    function setSymbol(string memory symbol_) public {
        IERC725Y(address(this)).setData(_LSP4_TOKEN_SYMBOL_KEY, bytes(symbol_));
    }
}
