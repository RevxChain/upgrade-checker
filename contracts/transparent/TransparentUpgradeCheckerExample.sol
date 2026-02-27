// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {TransparentUpgradeChecker} from "./TransparentUpgradeChecker.sol";

contract TransparentUpgradeCheckerExample is TransparentUpgradeChecker, TransparentUpgradeableProxy {

    constructor(
        address newImplementation, 
        address initialOwner, 
        bytes memory data
    ) TransparentUpgradeChecker(newImplementation) TransparentUpgradeableProxy(newImplementation, initialOwner, data) {
        InterfaceIdsRegistry.setInterfaceId(type(IAccessControl).interfaceId, true);
        _checkInterfaces(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    function _targetContractName() internal pure override returns(string memory targetContractName) {
        return "ImplementationForTransparent";
    }

    function _fallback() internal override {
        _checkOverallBeforeFallback();
        super._fallback();
    }

}

contract ImplementationForTransparent is UpgradeCheckerImplementation, AccessControlUpgradeable {

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

    function contractName() public pure override returns(string memory thisContractName) {
        return "ImplementationForTransparent";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, UpgradeCheckerImplementation) returns(bool supported) {
        return UpgradeCheckerImplementation.supportsInterface(interfaceId) || AccessControlUpgradeable.supportsInterface(interfaceId);
    }

}