// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UpgradeChecker} from "../UpgradeChecker.sol";

abstract contract UUPSUpgradeChecker is UpgradeChecker, UpgradeCheckerImplementation {

    function _targetContractName() internal view virtual override returns(string memory targetContractName) {
        return contractName();
    }

}