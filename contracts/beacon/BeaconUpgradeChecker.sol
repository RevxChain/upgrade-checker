// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UpgradeChecker} from "../UpgradeChecker.sol";

abstract contract BeaconUpgradeChecker is UpgradeChecker {

    constructor(address newImplementation) {
        _checkContractName(newImplementation);
    }

}