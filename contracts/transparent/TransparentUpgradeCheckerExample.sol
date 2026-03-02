// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {TransparentUpgradeChecker} from "./TransparentUpgradeChecker.sol";

/**
 * @title TransparentUpgradeCheckerExample
 * @notice A concrete implementation of a transparent upgradeable proxy with integrated upgrade validation.
 * @dev Combines {TransparentUpgradeableProxy} from OpenZeppelin with {TransparentUpgradeChecker}
 *      to provide a proxy that validates all implementation upgrades before accepting them.
 * 
 * If {ERC165} interface validation is not required, use the {_checkContractNameBeforeFallback} function only. 
 * In this case, there is no need for the {InterfaceIdsRegistry} library.
 * 
 * IMPORTANT: The default {TransparentUpgradeChecker} implementation is configured for use with the 
 * OpenZeppelin implementation of {TransparentUpgradeableProxy} using {ERC1967} and 
 * {ITransparentUpgradeableProxy} interface. For other implementations, you MUST override 
 * the {_detectUpgradeCall()} function and add custom logic for detecting upgrade calls, 
 * as well as a desired validation function call.
 * 
 * IMPORTANT: This is an example contract using unaudited code.
 * Do not use this code in production before covering it with tests.
 */
contract TransparentUpgradeCheckerExample is TransparentUpgradeChecker, TransparentUpgradeableProxy {

    /**
     * @notice Initializes a new transparent proxy with an implementation, owner, and optional init data.
     * @dev Calls both parent constructors. The {TransparentUpgradeChecker} constructor validates
     *      the initial implementation. Also registers {IAccessControl} as a required interface for implementation.
     * @param newImplementation The address of the initial implementation contract.
     * @param initialOwner The address that will own and control this proxy (owner of {ProxyAdmin}).
     * @param data Optional initialization data to pass to the implementation during deployment.
     * @custom:reverts UpgradeChecker__InvalidImplementation if {newImplementation} fails validation.
     */
    constructor(
        address newImplementation, 
        address initialOwner, 
        bytes memory data
    ) TransparentUpgradeChecker(newImplementation) TransparentUpgradeableProxy(newImplementation, initialOwner, data) {
        InterfaceIdsRegistry.setInterfaceId(type(IAccessControl).interfaceId, true);
        _checkInterfaces(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    /**
     * @notice Returns the expected contract name for valid implementations.
     * @dev Overrides {UpgradeChecker._targetContractName} to specify the required implementation name.
     * @return targetContractName The required contract name.
     */
    function _targetContractName() internal pure override returns(string memory targetContractName) {
        return "ImplementationForTransparent";
    }

    /**
     * @notice Intercepts fallback calls to validate upgrades before delegation.
     * @dev Overrides {TransparentUpgradeableProxy._fallback} to call {_checkOverallBeforeFallback}
     *      before delegating to the parent implementation. This ensures all upgrades are validated.
     */
    function _fallback() internal override {
        _checkOverallBeforeFallback();
        super._fallback();
    }

}

/**
 * @title ImplementationForTransparent
 * @notice Example implementation contract compatible with {TransparentUpgradeCheckerExample}.
 * @dev Inherits from both {UpgradeCheckerImplementation} and {AccessControlUpgradeable}
 *      to provide upgrade safety features.
 * 
 * IMPORTANT: This is an example contract using unaudited code.
 * Do not use this code in production before covering it with tests.
 */
contract ImplementationForTransparent is UpgradeCheckerImplementation, AccessControlUpgradeable {

    /**
     * @notice Disables initializers in the constructor to prevent initialization attacks.
     * @dev This is required for upgrade-safe implementations using the OpenZeppelin upgrades plugin.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes access control with a default admin.
     * @param defaultAdmin The address to grant the {DEFAULT_ADMIN_ROLE}.
     */
    function initialize(address defaultAdmin) external initializer() {
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    /**
     * @notice Enables or disables interface checking for future upgrades.
     * @dev Only callable by addresses with {DEFAULT_ADMIN_ROLE}.
     * @param enable {true} to enable checks, {false} to disable them.
     * @custom:reverts AccessControl__UnauthorizedAccount if {msg.sender} does not have {DEFAULT_ADMIN_ROLE}.
     */
    function enableInterfacesCheck(bool enable) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    /**
     * @notice Adds or removes a required interface ID.
     * @dev Only callable by addresses with {DEFAULT_ADMIN_ROLE}.
     * @param interfaceId The 4-byte interface ID to register or unregister.
     * @param add {true} to add, {false} to remove.
     * @custom:reverts AccessControl__UnauthorizedAccount if {msg.sender} does not have {DEFAULT_ADMIN_ROLE}.
     */
    function setInterfaceId(bytes4 interfaceId, bool add) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    /**
     * @notice Returns whether interface checking is currently enabled.
     * @return isInterfacesCheckEnabled {true} if enabled, {false} otherwise.
     */
    function getInterfacesCheckEnabled() external view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    /**
     * @notice Returns all currently registered required interface IDs.
     * @return interfaceIds Array of required interface selectors.
     */
    function getInterfaceIds() external view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

    /**
     * @notice Returns the contract name for upgrade validation.
     * @return thisContractName The contract identifier.
     */
    function contractName() public pure override returns(string memory thisContractName) {
        return "ImplementationForTransparent";
    }

    /**
     * @notice Declares support for both {UpgradeCheckerImplementation} and {AccessControlUpgradeable} interfaces.
     * @dev Overrides both parent implementations to ensure proper interface support declaration.
     * @param interfaceId The interface ID to check for support.
     * @return supported {true} if {interfaceId} is supported by either parent, {false} otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, UpgradeCheckerImplementation) returns(bool supported) {
        return UpgradeCheckerImplementation.supportsInterface(interfaceId) || AccessControlUpgradeable.supportsInterface(interfaceId);
    }

}