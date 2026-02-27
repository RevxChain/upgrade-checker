// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ImplementationForTransparent} from "../transparent/TransparentUpgradeCheckerExample.sol";
import {ImplementationForBeacon} from "../beacon/BeaconUpgradeCheckerExample.sol";
import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {UUPSUpgradeCheckerExample} from "../uups/UUPSUpgradeCheckerExample.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {InterfaceIdsRegistryMock} from "./InterfaceIdsRegistryMock.sol";

contract InvalidImplementationIncorrectName is UpgradeCheckerImplementation {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address /* defaultAdmin */) external {

    }

    function contractName() public pure override returns(string memory thisContractName) {
        return "InvalidImplementationIncorrectName";
    }
}

contract BeaconInvalidImplementationNoSupportedInterfaces {

    function contractName() external pure returns(string memory thisContractName) {
        return "ImplementationForBeacon";
    }
}

contract BeaconInvalidImplementationSupportedInterfaces is ImplementationForBeacon, InterfaceIdsRegistryMock {

    function supportsInterface(bytes4 interfaceId) public view override returns(bool supported) {
        bytes4[] memory _supportedInterfaces = getInterfaceIds();

        for (uint256 i; _supportedInterfaces.length > i; i++) {
            if (interfaceId == _supportedInterfaces[i]) return true;
        }
    }
}

contract TransparentInvalidImplementationNoSupportedInterfaces {

    function initialize(address /* defaultAdmin */) external {

    }

    function contractName() external pure returns(string memory thisContractName) {
        return "ImplementationForTransparent";
    }
}

contract TransparentInvalidImplementationSupportedInterfaces is ImplementationForTransparent {

    function enableInterfacesCheckPure(bool enable) external {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    function setInterfaceIdPure(bytes4 interfaceId, bool add) external {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns(bool supported) {
        bytes4[] memory _supportedInterfaces = InterfaceIdsRegistry.getInterfaceIds();

        for (uint256 i; _supportedInterfaces.length > i; i++) {
            if (interfaceId == _supportedInterfaces[i]) return true;
        }
    }
}

contract UUPSInvalidImplementationNoSupportedInterfaces {

    function contractName() external pure returns(string memory thisContractName) {
        return "UUPSUpgradeCheckerExample";
    }
}

contract UUPSInvalidImplementationSupportedInterfaces is UUPSUpgradeCheckerExample {

    function setInterfaceId(bytes4 interfaceId, bool add) external {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    function getInterfaceIds() external view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

    function supportsInterface(bytes4 interfaceId) public view override returns(bool supported) {
        bytes4[] memory _supportedInterfaces = InterfaceIdsRegistry.getInterfaceIds();

        for (uint256 i; _supportedInterfaces.length > i; i++) {
            if (interfaceId == _supportedInterfaces[i]) return true;
        }
    }
}