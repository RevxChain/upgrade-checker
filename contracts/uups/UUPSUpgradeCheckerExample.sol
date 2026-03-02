// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UUPSUpgradeChecker} from "./UUPSUpgradeChecker.sol";

/**
 * @title UUPSUpgradeCheckerExample
 * @notice Example UUPS implementation with integrated upgrade validation and access control.
 * @dev Combines {AccessControlUpgradeable}, {UUPSUpgradeChecker}, and {UUPSUpgradeable}
 *      to provide a fully functional upgradeable implementation with role-based upgrade authorization
 *      and comprehensive upgrade validation. Validates only contract name and {IAccessControl} interface.
 * 
 * If {ERC165} interface validation is not required, use the {_checkContractName} function only. 
 * In this case, there is no need for the {InterfaceIdsRegistry} library.
 * 
 * IMPORTANT: This is an example contract using unaudited code.
 * Do not use this code in production before covering it with tests.
 */
contract UUPSUpgradeCheckerExample is AccessControlUpgradeable, UUPSUpgradeChecker, UUPSUpgradeable {

    /**
     * @notice Disables initializers to prevent initialization attacks.
     * @dev Required for upgrade-safe implementations using the OpenZeppelin upgrades plugin.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes access control with a default admin.
     * @param defaultAdmin The address to grant {DEFAULT_ADMIN_ROLE}.
     */
    function initialize(address defaultAdmin) external initializer() {
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    /**
     * @notice Enables or disables interface checking for future upgrades.
     * @dev Only callable by {DEFAULT_ADMIN_ROLE}.
     * @param enable {true} to enable, {false} to disable.
     * @custom:reverts AccessControl__UnauthorizedAccount if {msg.sender} lacks {DEFAULT_ADMIN_ROLE}.
     */
    function enableInterfacesCheck(bool enable) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    /**
     * @notice Returns the contract name for upgrade validation.
     * @return thisContractName The contract identifier ("UUPSUpgradeCheckerExample").
     */
    function contractName() public pure virtual override returns(string memory thisContractName) {
        return "UUPSUpgradeCheckerExample";
    }

    /**
     * @notice Returns whether interface checking is currently enabled.
     * @return isInterfacesCheckEnabled {true} if enabled, {false} otherwise.
     */
    function getInterfacesCheckEnabled() external view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    /**
     * @notice Declares support for {AccessControlUpgradeable} and {UpgradeCheckerImplementation} interfaces.
     * @param interfaceId The interface ID to check.
     * @return supported {true} if supported by either parent, {false} otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, UpgradeCheckerImplementation) returns(bool supported) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || UpgradeCheckerImplementation.supportsInterface(interfaceId);
    }

    /**
     * @notice Authorizes an upgrade and validates the new implementation.
     * @dev Called by {UUPSUpgradeable} during upgrades. Validates contract name and {IAccessControl} interface support.
     * @param newImplementation The address of the new implementation.
     * @custom:reverts AccessControl__UnauthorizedAccount if {msg.sender} lacks {DEFAULT_ADMIN_ROLE}.
     * @custom:reverts UpgradeChecker__InvalidImplementation if validation fails.
     */
    function _authorizeUpgrade(address newImplementation) internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _checkContractName(newImplementation);

        // You can hardcode the required interfaces if {InterfaceIdsRegistry} management is unnecessary.
        // This may be changed in the next upgrade. Not recommended for use with other proxy patterns.
        bytes4[] memory _interfaceIds = new bytes4[](1);
        _interfaceIds[0] = type(IAccessControl).interfaceId;
        
        _checkInterfaces(newImplementation, _interfaceIds);
    }
    
}

/**
 * @title UUPSUpgradeCheckerExampleTwo
 * @notice Example UUPS implementation with full upgrade validation using registry-managed interfaces.
 * @dev Similar to {UUPSUpgradeCheckerExample} but performs comprehensive validation during upgrades
 *      using all interfaces registered in {InterfaceIdsRegistry}. Supports runtime interface configuration.
 * 
 * If {ERC165} interface validation is not required, use the {_checkContractName} function only. 
 * In this case, there is no need for the {InterfaceIdsRegistry} library.
 * 
 * IMPORTANT: This is an example contract using unaudited code.
 * Do not use this code in production before covering it with tests.
 */
contract UUPSUpgradeCheckerExampleTwo is AccessControlUpgradeable, UUPSUpgradeChecker, UUPSUpgradeable {

    /**
     * @notice Disables initializers to prevent initialization attacks.
     * @dev Required for upgrade-safe implementations.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes access control with a default admin.
     * @param defaultAdmin The address to grant {DEFAULT_ADMIN_ROLE}.
     */
    function initialize(address defaultAdmin) external initializer() {
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    /**
     * @notice Enables or disables interface checking.
     * @dev Only callable by {DEFAULT_ADMIN_ROLE}.
     * @param enable {true} to enable, {false} to disable.
     * @custom:reverts AccessControl__UnauthorizedAccount if unauthorized.
     */
    function enableInterfacesCheck(bool enable) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    /**
     * @notice Adds or removes a required interface ID.
     * @dev Only callable by {DEFAULT_ADMIN_ROLE}.
     * @param interfaceId The 4-byte interface ID to register or unregister.
     * @param add {true} to add, {false} to remove.
     * @custom:reverts AccessControl__UnauthorizedAccount if unauthorized.
     */
    function setInterfaceId(bytes4 interfaceId, bool add) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    /**
     * @notice Returns whether interface checking is enabled.
     * @return isInterfacesCheckEnabled {true} if enabled, {false} otherwise.
     */
    function getInterfacesCheckEnabled() external view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    /**
     * @notice Returns all registered required interface IDs.
     * @return interfaceIds Array of required interface selectors.
     */
    function getInterfaceIds() external view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

    /**
     * @notice Returns the contract name for upgrade validation.
     * @return thisContractName The contract identifier ("UUPSUpgradeCheckerExample").
     */
    function contractName() public pure virtual override returns(string memory thisContractName) {
        return "UUPSUpgradeCheckerExample";
    }

    /**
     * @notice Declares support for {AccessControlUpgradeable} and {UpgradeCheckerImplementation} interfaces.
     * @param interfaceId The interface ID to check.
     * @return supported {true} if supported, {false} otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, UpgradeCheckerImplementation) returns(bool supported) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || UpgradeCheckerImplementation.supportsInterface(interfaceId);
    }

    /**
     * @notice Authorizes an upgrade and validates using all registered interfaces.
     * @dev Called by {UUPSUpgradeable} during upgrades. Performs comprehensive validation
     *      including all interfaces in {InterfaceIdsRegistry}.
     * @param newImplementation The address of the new implementation.
     * @custom:reverts AccessControl__UnauthorizedAccount if {msg.sender} lacks {DEFAULT_ADMIN_ROLE}.
     * @custom:reverts UpgradeChecker__InvalidImplementation if validation fails.
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {
        _checkOverall(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }
    
}