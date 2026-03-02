// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";

/**
 * @title InterfaceIdsRegistryMock
 * @notice Mock contract exposing internal {InterfaceIdsRegistry} functions for testing.
 * @dev Provides public wrappers around the internal library functions to enable testing
 *      of interface registry functionality in isolation. All functions delegate to the library.
 */
contract InterfaceIdsRegistryMock {

    /**
     * @notice Enables or disables interface validation.
     * @dev Public wrapper around {InterfaceIdsRegistry.enableInterfacesCheck}.
     * @param enable {true} to enable checks, {false} to disable them.
     */
    function enableInterfacesCheck(bool enable) external {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    /**
     * @notice Adds or removes a required interface ID.
     * @dev Public wrapper around {InterfaceIdsRegistry.setInterfaceId}.
     * @param interfaceId The 4-byte interface ID to register or unregister.
     * @param add {true} to add, {false} to remove.
     */
    function setInterfaceId(bytes4 interfaceId, bool add) external {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    /**
     * @notice Returns whether interface checking is currently enabled.
     * @dev Public wrapper around {InterfaceIdsRegistry.getInterfacesCheckEnabled}.
     * @return isInterfacesCheckEnabled {true} if enabled, {false} otherwise.
     */
    function getInterfacesCheckEnabled() public view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    /**
     * @notice Returns all currently registered interface IDs.
     * @dev Public wrapper around {InterfaceIdsRegistry.getInterfaceIds}.
     * @return interfaceIds Array of registered interface selectors.
     */
    function getInterfaceIds() public view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

}
