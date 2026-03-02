// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UpgradeChecker} from "../UpgradeChecker.sol";

/**
 * @title TransparentUpgradeChecker
 * @notice Abstract base contract providing upgrade validation for Transparent proxy patterns.
 * @dev Extends {UpgradeChecker} to integrate upgrade validation with OpenZeppelin's
 *      {TransparentUpgradeableProxy}.
 * 
 * IMPORTANT: The default {TransparentUpgradeChecker} implementation is configured for use with the 
 * OpenZeppelin implementation of {TransparentUpgradeableProxy} using {ERC1967} and 
 * {ITransparentUpgradeableProxy} interface. For other implementations, you MUST override 
 * the {_detectUpgradeCall()} function and add custom logic for detecting upgrade calls, 
 * as well as a desired validation function call.
 */
abstract contract TransparentUpgradeChecker is UpgradeChecker {

    /**
     * @notice Initializes the transparent proxy with validation of the initial implementation.
     * @dev Performs a contract name validation check on the provided implementation address
     *      before the proxy is fully initialized. If validation fails, deployment reverts.
     * @param newImplementation The address of the initial implementation contract to validate.
     * @custom:reverts UpgradeChecker__InvalidImplementation if {newImplementation} does not pass
     *        the contract name validation check.
     */
    constructor(address newImplementation) {
        _checkContractName(newImplementation);
    }

    /**
     * @notice Validates the implementation and performs full upgrade checks before fallback.
     * @dev Detects if the current call is an upgrade via {_detectUpgradeCall}. If it is,
     *      executes {_checkOverall} with the new implementation. Safe to call from _fallback.
     */
    function _checkOverallBeforeFallback() internal view virtual {
        (bool _isUpgradeCall, address _newImplementation) = _detectUpgradeCall();

        if (_isUpgradeCall) _checkOverall(_newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    /**
     * @notice Validates only the contract name before fallback.
     * @dev Detects if the current call is an upgrade via {_detectUpgradeCall}. If it is,
     *      executes {_checkContractName} with the new implementation. Used for selective validation.
     */
    function _checkContractNameBeforeFallback() internal view virtual {
        (bool _isUpgradeCall, address _newImplementation) = _detectUpgradeCall();

        if (_isUpgradeCall) _checkContractName(_newImplementation);
    }

    /**
     * @notice Validates only ERC165 interface support before fallback.
     * @dev Detects if the current call is an upgrade via {_detectUpgradeCall}. If it is,
     *      executes {_checkInterfaces} with the new implementation. Used for selective validation.
     */
    function _checkInterfacesBeforeFallback() internal view virtual {
        (bool _isUpgradeCall, address _newImplementation) = _detectUpgradeCall();

        if (_isUpgradeCall) _checkInterfaces(_newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    /**
     * @notice Detects whether the current call is an upgrade call via the proxy admin.
     * @dev Checks two conditions:
     *      1. The caller is the {ProxyAdmin} via {ERC1967Utils.getAdmin}
     *      2. The function selector is for {upgradeToAndCall}
     *      If both are true, decodes and returns the new implementation address.
     * @return isUpgradeCall {true} if this is an upgrade call from the admin, {false} otherwise.
     * @return newImplementation The address of the new implementation from the call data,
     *         or zero address if this is not an upgrade call.
     */
    function _detectUpgradeCall() internal view virtual returns(bool isUpgradeCall, address newImplementation) {
        if (msg.sender == ERC1967Utils.getAdmin() && msg.sig == ITransparentUpgradeableProxy.upgradeToAndCall.selector) {
            (newImplementation, /* bytes memory data */) = abi.decode(msg.data[4:], (address, bytes));

            return (true, newImplementation);
        }
    }

}