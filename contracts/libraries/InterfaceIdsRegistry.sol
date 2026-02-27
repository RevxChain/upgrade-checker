// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library InterfaceIdsRegistry {
    using EnumerableSet for EnumerableSet.Bytes4Set;

    bytes4 private constant INTERFACE_ID_INVALID = 0xffffffff;

    /// @custom:storage-location erc7201:UpgradeChecker.storage.InterfaceIdsRegistry
    struct InterfaceIdsRegistryStorage {
        bool _interfacesCheckDisabled;
        EnumerableSet.Bytes4Set _interfaceIds;
    }

    // keccak256(abi.encode(uint256(keccak256("UpgradeChecker.storage.InterfaceIdsRegistry")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant INTERFACE_IDS_REGISTRY_STORAGE_LOCATION = 0xb3567140b780d0e6eae18a93d996909c6c854e99daead678dce9f5547099f300;

    error InterfaceIdsRegistry__InvalidInterfaceId();

    event InterfacesCheckEnabled(bool isEnabled);
    event InterfaceIdSet(bytes4 interfaceId, bool indexed isAdded);
    
    function enableInterfacesCheck(bool enable) internal {
        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        $._interfacesCheckDisabled = !enable;

        emit InterfacesCheckEnabled(enable);
    }

    function setInterfaceId(bytes4 interfaceId, bool add) internal {
        require(interfaceId != INTERFACE_ID_INVALID, InterfaceIdsRegistry__InvalidInterfaceId());

        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        if (add ? $._interfaceIds.add(interfaceId) : $._interfaceIds.remove(interfaceId)) {
            emit InterfaceIdSet(interfaceId, add);
        }
    }

    function getInterfacesCheckEnabled() internal view returns(bool isInterfacesCheckEnabled) {
        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        return !$._interfacesCheckDisabled;
    }

    function getInterfaceIds() internal view returns(bytes4[] memory interfaceIds) {
        InterfaceIdsRegistryStorage storage $ = _getInterfaceIdsRegistryStorage();

        return $._interfaceIds.values();
    }

    function _getInterfaceIdsRegistryStorage() private pure returns(InterfaceIdsRegistryStorage storage $) {
        assembly {
            $.slot := INTERFACE_IDS_REGISTRY_STORAGE_LOCATION
        }
    }

}