// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {BeaconUpgradeChecker} from "./BeaconUpgradeChecker.sol";

/**
 * @title BeaconUpgradeCheckerExample
 * @notice A concrete implementation of an upgradeable beacon proxy with integrated upgrade validation.
 * @dev Combines {UpgradeableBeacon} from OpenZeppelin with {BeaconUpgradeChecker} to provide
 *      a beacon that validates all implementation upgrades before accepting them.
 *      This contract demonstrates how to use the upgrade checker pattern with beacon proxies.
 *
 * If {ERC165} interface validation is not required, use the {_checkContractName} function only. 
 * In this case, there is no need for the {InterfaceIdsRegistry} library.
 * 
 * IMPORTANT: This is an example contract using unaudited code.
 * Do not use this code in production before covering it with tests.
 */
contract BeaconUpgradeCheckerExample is UpgradeableBeacon, BeaconUpgradeChecker {

    /**
     * @notice Initializes a new beacon with an initial implementation and owner.
     * @dev Calls both parent constructors to set up the beacon and perform initial validation.
     *      The {BeaconUpgradeChecker} constructor validates the initial implementation before
     *      {UpgradeableBeacon} is initialized.
     * @param implementation The address of the initial implementation contract.
     *        Must be a valid contract implementing {UpgradeCheckerImplementation}.
     * @param initialOwner The address that will own and control this beacon.
     *        Only the owner can call {upgradeTo} and configuration functions.
     * @custom:reverts UpgradeChecker__InvalidImplementation if {implementation} fails validation.
     */
    constructor(
        address implementation,
        address initialOwner
    ) BeaconUpgradeChecker(implementation) UpgradeableBeacon(implementation, initialOwner) {

    }

    /**
     * @notice Upgrades the beacon to point to a new implementation.
     * @dev Performs comprehensive upgrade validation before delegating to the parent {upgradeTo}.
     *      Validates both contract name matching and required interface support via {_checkOverall}.
     * @param newImplementation The address of the new implementation contract to upgrade to.
     *        Must pass name validation and support all interfaces registered in {InterfaceIdsRegistry}.
     * @custom:reverts UpgradeChecker__InvalidImplementation if {newImplementation} fails name or interface validation checks.
     * @custom:reverts Ownable__Unauthorized if the caller is not the beacon owner.
     */
    function upgradeTo(address newImplementation) public override {
        _checkOverall(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
        super.upgradeTo(newImplementation);
    }

    /**
     * @notice Enables or disables interface checking for future upgrades.
     * @dev Only the beacon owner can call this function.
     *      When disabled, interface validation is skipped during upgrades (emergency stop).
     * @param enable Boolean flag: {true} to enable checks, {false} to disable them.
     * @custom:reverts Ownable__Unauthorized if the caller is not the beacon owner.
     */
    function enableInterfacesCheck(bool enable) external onlyOwner() {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    /**
     * @notice Adds or removes a required interface ID for implementations.
     * @dev Only the beacon owner can call this function.
     *      Interface IDs are used to validate that upgrades implement required functionality.
     * @param interfaceId The 4-byte ERC165 interface identifier (e.g., {type(IMyInterface).interfaceId}).
     * @param add Boolean flag: {true} to add the interface requirement, {false} to remove it.
     * @custom:reverts Ownable__Unauthorized if the caller is not the beacon owner.
     * @custom:reverts InterfaceIdsRegistry__InvalidInterfaceId if {interfaceId} is {0xffffffff}.
     */
    function setInterfaceId(bytes4 interfaceId, bool add) external onlyOwner() {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    /**
     * @notice Returns whether interface checking is currently enabled.
     * @dev This is a read-only function that queries the current validation state.
     * @return isInterfacesCheckEnabled {true} if interface validation is enabled, {false} otherwise.
     */
    function getInterfacesCheckEnabled() external view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    /**
     * @notice Returns all currently registered required interface IDs.
     * @dev Implementations must support all interfaces in this array to pass upgrade validation.
     *      Note that implementations must also support {IUpgradeChecker} and {IERC165} interfaces
     *      even if this array is empty.
     * @return interfaceIds Array of 4-byte interface selectors that implementations must support.
     */
    function getInterfaceIds() external view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

    /**
     * @notice Returns the expected contract name for valid implementations.
     * @dev This is an internal override of {UpgradeChecker._targetContractName}.
     *      All implementations must return exactly this string from their {contractName} function.
     * @return targetContractName The required contract name string.
     */
    function _targetContractName() internal view virtual override returns(string memory targetContractName) {
        return "ImplementationForBeacon";
    }

}

/**
 * @title ImplementationForBeacon
 * @notice Example implementation contract compatible with {BeaconUpgradeCheckerExample}.
 * @dev Inherits from {UpgradeCheckerImplementation} to provide required upgrade safety features.
 *      This contract demonstrates how to add the validation interface to implementation for beacon proxies.
 *      If the implementation inherits from other ERC165-supporting contracts, you must override {supportsInterface}
 *      to declare support for all parent interfaces.
 */
contract ImplementationForBeacon is UpgradeCheckerImplementation {

    /**
     * @notice Returns the contract name for upgrade validation.
     * @dev Must match the expected name from {BeaconUpgradeCheckerExample._targetContractName}.
     * @return thisContractName The contract identifier string.
     */
    function contractName() public pure override returns(string memory thisContractName) {
        return "ImplementationForBeacon";
    }

}