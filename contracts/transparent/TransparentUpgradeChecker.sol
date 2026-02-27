// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import {InterfaceIdsRegistry} from "../libraries/InterfaceIdsRegistry.sol";
import {UpgradeChecker} from "../UpgradeChecker.sol";

abstract contract TransparentUpgradeChecker is UpgradeChecker {

    constructor(address newImplementation) {
        _checkContractName(newImplementation);
    }

    function _checkOverallBeforeFallback() internal view virtual {
        (bool _isUpgradeCall, address _newImplementation) = _detectUpgradeCall();

        if (_isUpgradeCall) _checkOverall(_newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    function _checkContractNameBeforeFallback() internal view virtual {
        (bool _isUpgradeCall, address _newImplementation) = _detectUpgradeCall();

        if (_isUpgradeCall) _checkContractName(_newImplementation);
    }

    function _checkInterfacesBeforeFallback() internal view virtual {
        (bool _isUpgradeCall, address _newImplementation) = _detectUpgradeCall();

        if (_isUpgradeCall) _checkInterfaces(_newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    function _detectUpgradeCall() internal view virtual returns(bool isUpgradeCall, address newImplementation) {
        if (msg.sender == ERC1967Utils.getAdmin() && msg.sig == ITransparentUpgradeableProxy.upgradeToAndCall.selector) {
            (newImplementation, /* bytes memory data */) = abi.decode(msg.data[4:], (address, bytes));

            return (true, newImplementation);
        }
    }

}