pragma solidity ^0.8.15;

import {Diamond} from "../Diamond.sol";
import {IDiamondLauncher} from "../interfaces/IDiamondLauncher.sol";

contract DiamondLauncherFacet is IDiamondLauncher {
    // launch a generic diamond, we create this separatate launch facet to reduce storage cost of our
    // specific NFT or generic contract Diamond contract launchers
    function launch(address owner, address diamondCutAddress, address diamondLoupeAddress) public returns (address) {
        Diamond diamond = new Diamond(owner, diamondCutAddress, diamondLoupeAddress);
        return address(diamond);
    }
}
