// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UpgradeChecker} from "../UpgradeChecker.sol";

/**
 * @title BeaconUpgradeChecker
 * @notice Abstract base contract that provides upgrade validation for Beacon proxy patterns.
 * @dev Extends {UpgradeChecker} to enforce contract name validation during beacon initialization.
 */
abstract contract BeaconUpgradeChecker is UpgradeChecker {

    /**
     * @notice Initializes the beacon with validation of the initial implementation.
     * @dev Performs a contract name validation check on the provided implementation address
     *      before the beacon is fully initialized.
     * @param newImplementation The address of the initial implementation contract to validate.
     *      This implementation must have a {contractName} function that returns the expected name.
     * @custom:reverts UpgradeChecker__InvalidImplementation if {newImplementation} does not pass
     *        the contract name validation check or if the contract is not found at the address.
     */
    constructor(address newImplementation) {
        _checkContractName(newImplementation);
    }

}