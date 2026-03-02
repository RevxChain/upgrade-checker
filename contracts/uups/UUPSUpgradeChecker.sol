// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UpgradeChecker} from "../UpgradeChecker.sol";

/**
 * @title UUPSUpgradeChecker
 * @notice Abstract base contract providing upgrade validation for UUPS proxy patterns.
 * @dev Combines {UpgradeChecker} (proxy-side validation) with {UpgradeCheckerImplementation}
 *      (implementation-side features) to integrate validation into UUPS upgradeable implementations.
 *      The {_targetContractName} returns the implementation's own contract name.
 */
abstract contract UUPSUpgradeChecker is UpgradeChecker, UpgradeCheckerImplementation {

    /**
     * @notice Returns the expected contract name by delegating to the implementation's {contractName}.
     * @dev Overrides {UpgradeChecker._targetContractName} to use the implementation's own name.
     *      This allows each UUPS implementation to define its own expected name.
     * @return targetContractName The contract name from {contractName}.
     */
    function _targetContractName() internal view virtual override returns(string memory targetContractName) {
        return contractName();
    }

}