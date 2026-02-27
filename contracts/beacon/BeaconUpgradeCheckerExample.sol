// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import {UpgradeCheckerImplementation} from "../UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {BeaconUpgradeChecker} from "./BeaconUpgradeChecker.sol";

contract BeaconUpgradeCheckerExample is UpgradeableBeacon, BeaconUpgradeChecker {

    constructor(
        address implementation,
        address initialOwner
    ) BeaconUpgradeChecker(implementation) UpgradeableBeacon(implementation, initialOwner) {

    }

    function upgradeTo(address newImplementation) public override {
        _checkOverall(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
        super.upgradeTo(newImplementation);
    }

    function enableInterfacesCheck(bool enable) external onlyOwner() {
        InterfaceIdsRegistry.enableInterfacesCheck(enable);
    }

    function setInterfaceId(bytes4 interfaceId, bool add) external onlyOwner() {
        InterfaceIdsRegistry.setInterfaceId(interfaceId, add);
    }

    function getInterfacesCheckEnabled() external view returns(bool isInterfacesCheckEnabled) {
        return InterfaceIdsRegistry.getInterfacesCheckEnabled();
    }

    function getInterfaceIds() external view returns(bytes4[] memory interfaceIds) {
        return InterfaceIdsRegistry.getInterfaceIds();
    }

    function _targetContractName() internal view virtual override returns(string memory targetContractName) {
        return "ImplementationForBeacon";
    }

}

contract ImplementationForBeacon is UpgradeCheckerImplementation {

    function contractName() public pure override returns(string memory thisContractName) {
        return "ImplementationForBeacon";
    }

}