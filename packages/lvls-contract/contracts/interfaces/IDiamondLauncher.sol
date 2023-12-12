// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDiamondLauncher {
    function launch(address owner, address diamondCutAddress, address diamondLoupeAddress) external returns (address);
}
