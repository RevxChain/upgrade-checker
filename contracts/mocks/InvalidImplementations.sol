// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ImplementationForTransparent} from "../transparent/TransparentUpgradeCheckerExample.sol";
import {ImplementationForBeacon} from "../beacon/BeaconUpgradeCheckerExample.sol";
import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {UUPSUpgradeCheckerExample} from "../uups/UUPSUpgradeCheckerExample.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {InterfaceIdsRegistryMock} from "./InterfaceIdsRegistryMock.sol";

/**
 * @title InvalidImplementationIncorrectName
 * @notice Test implementation with incorrect contract name.
 * @dev Used to verify that {UpgradeChecker._checkContractName} correctly rejects
 *      implementations that return a name different from the expected value.
 *      This contract should fail upgrade validation due to name mismatch.
 */
contract InvalidImplementationIncorrectName is UpgradeCheckerImplementation {

    /**
     * @notice Disables initializers to prevent initialization attacks.
     * @custom:oz-upgrades-unsafe-allow constructor
     */
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Placeholder initialization function.
     * @custom:unused-param defaultAdmin Unused parameter for test.
     */
    function initialize(address /* defaultAdmin */) external {

    }

    /**
     * @notice Returns an incorrect contract name.
     * @return thisContractName The wrong name ("InvalidImplementationIncorrectName" instead of expected).
     */
    function contractName() public pure override returns(string memory thisContractName) {
        return "InvalidImplementationIncorrectName";
    }
}

/**
 * @title BeaconInvalidImplementationNoSupportedInterfaces
 * @notice Test invalid implementation missing {supportsInterface}.
 * @dev Used to verify that {UpgradeChecker._checkInterfaces} correctly rejects
 *      contracts that don't implement {supportsInterface}. This contract will fail
 *      during staticcall attempts to check interface support.
 */
contract BeaconInvalidImplementationNoSupportedInterfaces {

    /**
     * @notice Returns the correct contract name.
     * @return thisContractName The expected name ("ImplementationForBeacon").
     */
    function contractName() external pure returns(string memory thisContractName) {
        return "ImplementationForBeacon";
    }
}

/**
 * @title BeaconInvalidImplementationSupportedInterfaces
 * @notice Test implementation with partial interface support.
 * @dev Extends {ImplementationForBeacon} but overrides {supportsInterface} to only
 *      return true for registered interfaces (doesn't include {IUpgradeChecker}).
 *      Used to verify validation detects missing required interfaces.
 */
contract BeaconInvalidImplementationSupportedInterfaces is ImplementationForBeacon, InterfaceIdsRegistryMock {

    /**
     * @notice Checks if the implementation supports an interface.
     * @dev Returns true only for interfaces in the registry, missing {IUpgradeChecker}.
     * @param interfaceId The interface ID to check.
     * @return supported {true} only if {interfaceId} is in the registry.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns(bool supported) {
        bytes4[] memory _supportedInterfaces = getInterfaceIds();

        for (uint256 i; _supportedInterfaces.length > i; i++) {
            if (interfaceId == _supportedInterfaces[i]) return true;
        }
    }
}

/**
 * @title TransparentInvalidImplementationNoSupportedInterfaces
 * @notice Test transparent implementation without {supportsInterface}.
 * @dev Used to verify interface validation fails for implementations missing the function.
 *      This contract should be rejected by transparent proxy upgrade validation.
 */
contract TransparentInvalidImplementationNoSupportedInterfaces {

    /**
     * @notice Placeholder initialization.
     * @custom:unused-param defaultAdmin Unused parameter.
     */
    function initialize(address /* defaultAdmin */) external {

    }

    /**
     * @notice Returns the expected contract name.
     * @return thisContractName The correct name ("ImplementationForTransparent").
     */
    function contractName() external pure returns(string memory thisContractName) {
        return "ImplementationForTransparent";
    }
}

/**
 * @title TransparentInvalidImplementationSupportedInterfaces
 * @notice Test transparent implementation with partial interface support.
 * @dev Extends {ImplementationForTransparent} but overrides {supportsInterface} to skip
 *      {IUpgradeChecker}. Used to test validation of interface requirements.
 */
contract TransparentInvalidImplementationSupportedInterfaces is ImplementationForTransparent {

    /**
     * @notice Wrapper for enabling interface checks (renames function).
     * @param enable Whether to enable checks.
     */
    function enableInterfacesCheckPure(bool enable) external {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    /**
     * @notice Wrapper for setting an interface (renames function for testing).
     * @param interfaceId The interface to register.
     * @param add Whether to add or remove.
     */
    function setInterfaceIdPure(bytes4 interfaceId, bool add) external {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    /**
     * @notice Checks support for interfaces, excluding {IUpgradeChecker}.
     * @param interfaceId The interface to check.
     * @return supported {true} only for registered interfaces, not for {IUpgradeChecker}.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns(bool supported) {
        bytes4[] memory _supportedInterfaces = InterfaceIdsRegistry.getInterfaceIds();

        for (uint256 i; _supportedInterfaces.length > i; i++) {
            if (interfaceId == _supportedInterfaces[i]) return true;
        }
    }
}

/**
 * @title UUPSInvalidImplementationNoSupportedInterfaces
 * @notice Test UUPS implementation without {supportsInterface}.
 * @dev Used to verify that UUPS upgrade validation correctly rejects
 *      implementations missing the {supportsInterface} function.
 */
contract UUPSInvalidImplementationNoSupportedInterfaces {

    /**
     * @notice Returns the correct contract name.
     * @return thisContractName The expected name ("UUPSUpgradeCheckerExample").
     */
    function contractName() external pure returns(string memory thisContractName) {
        return "UUPSUpgradeCheckerExample";
    }
}

/**
 * @title UUPSInvalidImplementationSupportedInterfaces
 * @notice Test UUPS implementation with partial interface support.
 * @dev Extends {UUPSUpgradeCheckerExample} but overrides {supportsInterface}
 *      to only support registered interfaces (excluding {IUpgradeChecker}).
 *      Used to test selective interface validation failures.
 */
contract UUPSInvalidImplementationSupportedInterfaces is UUPSUpgradeCheckerExample {

    /**
     * @notice Adds or removes a registered interface.
     * @param interfaceId The interface to register/unregister.
     * @param add Whether to add or remove.
     */
    function setInterfaceId(bytes4 interfaceId, bool add) external {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    /**
     * @notice Returns all registered interface IDs.
     * @return interfaceIds Array of required interfaces.
     */
    function getInterfaceIds() external view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

    /**
     * @notice Checks interface support, excluding {IUpgradeChecker}.
     * @param interfaceId The interface to check.
     * @return supported {true} only for registered interfaces.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns(bool supported) {
        bytes4[] memory _supportedInterfaces = InterfaceIdsRegistry.getInterfaceIds();

        for (uint256 i; _supportedInterfaces.length > i; i++) {
            if (interfaceId == _supportedInterfaces[i]) return true;
        }
    }
}