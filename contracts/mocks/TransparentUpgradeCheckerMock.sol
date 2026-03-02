// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {TransparentUpgradeChecker} from "../transparent/TransparentUpgradeChecker.sol";

/**
 * @title TransparentUpgradeCheckerMockCheckContract
 * @notice Mock transparent proxy that validates only contract names during upgrades.
 * @dev Used for testing {TransparentUpgradeChecker} behavior with selective validation.
 *      Calls {_checkContractNameBeforeFallback} instead of comprehensive validation.
 */
contract TransparentUpgradeCheckerMockCheckContract is TransparentUpgradeChecker, TransparentUpgradeableProxy {

    /**
     * @notice Initializes a transparent proxy with an implementation.
     * @dev Calls both parent constructors to set up the proxy and perform initial validation.
     * @param newImplementation The address of the initial implementation.
     * @param initialOwner The owner/admin of the proxy.
     * @param data Optional initialization data.
     */
    constructor(
        address newImplementation,
        address initialOwner,
        bytes memory data
    ) TransparentUpgradeChecker(newImplementation) TransparentUpgradeableProxy(newImplementation, initialOwner, data) {

    }

    /**
     * @notice Returns the expected contract name for implementations.
     * @return targetContractName The required name ("ImplementationForTransparent").
     */
    function _targetContractName() internal pure override returns(string memory targetContractName) {
        return "ImplementationForTransparent";
    }

    /**
     * @notice Validates only contract names before delegating to the implementation.
     * @dev Overrides {TransparentUpgradeableProxy._fallback} to call {_checkContractNameBeforeFallback}
     *      instead of full validation, testing selective validation behavior.
     */
    function _fallback() internal virtual override {
        _checkContractNameBeforeFallback();
        super._fallback();
    }

}

/**
 * @title TransparentUpgradeCheckerMockCheckInterfaces
 * @notice Mock transparent proxy that validates only ERC165 interfaces during upgrades.
 * @dev Extends {TransparentUpgradeCheckerMockCheckContract} to validate only interface support.
 *      Used for testing selective interface validation in transparent proxies.
 */
contract TransparentUpgradeCheckerMockCheckInterfaces is TransparentUpgradeCheckerMockCheckContract {

    /**
     * @notice Initializes the mock proxy.
     * @dev Passes all parameters to parent constructor.
     * @param newImplementation The address of the initial implementation.
     * @param initialOwner The owner/admin of the proxy.
     * @param data Optional initialization data.
     */
    constructor(
        address newImplementation,
        address initialOwner,
        bytes memory data
    ) TransparentUpgradeCheckerMockCheckContract(newImplementation, initialOwner, data) {

    }

    /**
     * @notice Validates only ERC165 interfaces before delegation.
     * @dev Overrides {TransparentUpgradeCheckerMockCheckContract._fallback} to call 
     *      {_checkInterfacesBeforeFallback} for interface-only validation testing.
     */
    function _fallback() internal override {
        _checkInterfacesBeforeFallback();
        TransparentUpgradeableProxy._fallback();
    }

}