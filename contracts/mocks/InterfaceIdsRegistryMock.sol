// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";

contract InterfaceIdsRegistryMock {

    function enableInterfacesCheck(bool enable) external {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    function setInterfaceId(bytes4 interfaceId, bool add) external {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    function getInterfacesCheckEnabled() public view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    function getInterfaceIds() public view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

}
