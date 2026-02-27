// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import {TransparentUpgradeChecker} from "../transparent/TransparentUpgradeChecker.sol";

contract TransparentUpgradeCheckerMockCheckContract is TransparentUpgradeChecker, TransparentUpgradeableProxy {

    constructor(
        address newImplementation,
        address initialOwner,
        bytes memory data
    ) TransparentUpgradeChecker(newImplementation) TransparentUpgradeableProxy(newImplementation, initialOwner, data) {

    }

    function _targetContractName() internal pure override returns(string memory targetContractName) {
        return "ImplementationForTransparent";
    }

    function _fallback() internal virtual override {
        _checkContractNameBeforeFallback();
        super._fallback();
    }

}

contract TransparentUpgradeCheckerMockCheckInterfaces is TransparentUpgradeCheckerMockCheckContract {

    constructor(
        address newImplementation,
        address initialOwner,
        bytes memory data
    ) TransparentUpgradeCheckerMockCheckContract(newImplementation, initialOwner, data) {

    }

    function _fallback() internal override {
        _checkInterfacesBeforeFallback();
        TransparentUpgradeableProxy._fallback();
    }

}