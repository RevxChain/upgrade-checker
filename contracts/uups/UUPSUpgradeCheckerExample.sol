// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UUPSUpgradeChecker} from "./UUPSUpgradeChecker.sol";

contract UUPSUpgradeCheckerExample is AccessControlUpgradeable, UUPSUpgradeChecker, UUPSUpgradeable {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) external initializer() {
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function enableInterfacesCheck(bool enable) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    function contractName() public pure virtual override returns(string memory thisContractName) {
        return "UUPSUpgradeCheckerExample";
    }

    function getInterfacesCheckEnabled() external view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, UpgradeCheckerImplementation) returns(bool supported) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || UpgradeCheckerImplementation.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyRole(DEFAULT_ADMIN_ROLE) {
        _checkContractName(newImplementation);

        bytes4[] memory _interfaceIds = new bytes4[](1);
        _interfaceIds[0] = type(IAccessControl).interfaceId;
        
        _checkInterfaces(newImplementation, _interfaceIds);
    }
    
}

contract UUPSUpgradeCheckerExampleTwo is AccessControlUpgradeable, UUPSUpgradeChecker, UUPSUpgradeable {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) external initializer() {
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function enableInterfacesCheck(bool enable) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    function setInterfaceId(bytes4 interfaceId, bool add) external onlyRole(DEFAULT_ADMIN_ROLE) {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    function getInterfacesCheckEnabled() external view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    function getInterfaceIds() external view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

    function contractName() public pure virtual override returns(string memory thisContractName) {
        return "UUPSUpgradeCheckerExample";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, UpgradeCheckerImplementation) returns(bool supported) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || UpgradeCheckerImplementation.supportsInterface(interfaceId);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {
        _checkOverall(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }
    
}