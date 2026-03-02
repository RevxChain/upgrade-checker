// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/**
 * @title InterfaceIdsRegistry
 * @notice Library managing persistent storage of required interface IDs for upgrade validation.
 * @dev Uses ERC7201 namespaced storage to avoid collisions with upgradeable contracts.
 *      Maintains a set of interface IDs that implementations must support and a flag
 *      to enable/disable interface checking. All functions are internal-only.
 * 
 * IMPORTANT: All internal functions MUST be implemented if interface validation is to be used.
 */
library InterfaceIdsRegistry {
    using EnumerableSet for EnumerableSet.Bytes4Set;

    /// @notice The invalid interface ID value (0xffffffff) that cannot be registered.
    bytes4 private constant INTERFACE_ID_INVALID = 0xffffffff;

    /**
     * @notice Struct containing all registry storage variables.
     * @dev Located at ERC7201 namespaced storage position to prevent collisions.
     * @custom:storage-location erc7201:UpgradeChecker.storage.InterfaceIdsRegistry
     */
    struct InterfaceIdsRegistryStorage {
        bool _interfacesCheckDisabled;
        EnumerableSet.Bytes4Set _interfaceIds;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("UpgradeChecker.storage.InterfaceIdsRegistry")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INTERFACE_IDS_REGISTRY_STORAGE_LOCATION = 0xb3567140b780d0e6eae18a93d996909c6c854e99daead678dce9f5547099f300;

    /**
     * @notice Emitted when interface validation is enabled or disabled.
     * @param isEnabled {true} if validation is enabled, {false} if disabled.
     */
    event InterfacesCheckEnabled(bool isEnabled);

    /**
     * @notice Emitted when an interface ID is registered or unregistered.
     * @param interfaceId The 4-byte interface ID that was added or removed.
     * @param isAdded {true} if the interface was added, {false} if removed.
     */
    event InterfaceIdSet(bytes4 interfaceId, bool indexed isAdded);

    /**
     * @notice Raised when attempting to register or unregister the invalid interface ID.
     * @dev The value 0xffffffff is reserved for ERC165 "no interface" and cannot be used.
     */
    error InterfaceIdsRegistry__InvalidInterfaceId();

    /**
     * @notice Enables or disables interface validation for upgrades.
     * @dev When disabled ({enable} = false), implementations won't have their interfaces checked.
     *      This provides an emergency stop mechanism for upgrades if validation needs to be bypassed.
     * @param enable {true} to enable interface checks, {false} to disable them.
     */
    function enableInterfacesCheck(bool enable) internal {
        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        $._interfacesCheckDisabled = !enable;

        emit InterfacesCheckEnabled(enable);
    }

    /**
     * @notice Adds or removes an interface ID from the registry.
     * @dev Cannot register 0xffffffff (reserved by ERC165). If adding and the ID is already present,
     *      or removing and the ID is not present, the set state doesn't change and no event is emitted.
     * @param interfaceId The 4-byte interface ID to register or unregister.
     * @param add {true} to add the interface, {false} to remove it.
     * @custom:reverts InterfaceIdsRegistry__InvalidInterfaceId if {interfaceId} is 0xffffffff.
     */
    function setInterfaceId(bytes4 interfaceId, bool add) internal {
        require(interfaceId != INTERFACE_ID_INVALID, InterfaceIdsRegistry__InvalidInterfaceId());

        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        if (add ? $._interfaceIds.add(interfaceId) : $._interfaceIds.remove(interfaceId)) {
            emit InterfaceIdSet(interfaceId, add);
        }
    }

    /**
     * @notice Returns whether interface validation is currently enabled.
     * @dev Checks the state of the internal flag (inverted for storage efficiency).
     * @return isInterfacesCheckEnabled {true} if interface validation is enabled, {false} otherwise.
     */
    function getInterfacesCheckEnabled() internal view returns(bool isInterfacesCheckEnabled) {
        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        return !$._interfacesCheckDisabled;
    }

    /**
     * @notice Returns all currently registered interface IDs.
     * @dev Returns an array of all interface IDs that implementations must support.
     *      The order of elements in the returned array is not guaranteed.
     * @return interfaceIds Array of 4-byte interface identifiers.
     */
    function getInterfaceIds() internal view returns(bytes4[] memory interfaceIds) {
        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        return $._interfaceIds.values();
    }

    //slither-disable-next-line uninitialized-storage
    function _getInterfaceIdsRegistryStorage() private pure returns(InterfaceIdsRegistryStorage storage $) {
        assembly {
            $.slot := INTERFACE_IDS_REGISTRY_STORAGE_LOCATION
        }
    }

}