// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface ILSP7XP {
    function mint(address to, uint256 amount, bool allowNonLSP1Recipient, bytes memory data) external;

    function burn(address account, uint256 amount, bytes memory data) external;

    function updateBaleances(address[] memory accounts, uint256[] memory amounts) external;

    function inactiveVirtualBalanceOf(address account) external view returns (uint256);

    function activeVirtualBalanceOf(address account) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function setDeacyRate(uint256 _decayRate) external;

    function listHolders() external view returns (address[] memory);

    function authorizedAmountFor(address operator, address tokenOwner) external view returns (uint256);
}
