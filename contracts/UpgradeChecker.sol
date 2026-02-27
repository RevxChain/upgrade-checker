// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import {InterfaceIdsRegistry} from "./libraries/InterfaceIdsRegistry.sol";
import {IUpgradeChecker} from "./interfaces/IUpgradeChecker.sol";

abstract contract UpgradeChecker {
    using ERC165Checker for address;

    function _targetContractName() internal view virtual returns(string memory targetContractName);

    function _checkOverall(address newImplementation, bytes4[] memory interfaceIds) internal view virtual {
        _checkContractName(newImplementation);
        _checkInterfaces(newImplementation, interfaceIds);
    }

    function _checkContractName(address newImplementation) internal view virtual {
        (
            bool _contractNameCallResult,
            bytes memory _contractNameCallResponse
        ) = newImplementation.staticcall(abi.encodeCall(IUpgradeChecker.contractName, ()));

        require(
            _contractNameCallResult && keccak256(_contractNameCallResponse) == keccak256(abi.encode(_targetContractName())),
            IUpgradeChecker.UpgradeChecker__InvalidImplementation()
        );
    }

    function _checkInterfaces(address newImplementation, bytes4[] memory interfaceIds) internal view virtual {
        if (InterfaceIdsRegistry.getInterfacesCheckEnabled()) {
            require(
                newImplementation.supportsInterface(type(IUpgradeChecker).interfaceId),
                IUpgradeChecker.UpgradeChecker__InvalidImplementation()
            );

            require(
                newImplementation.supportsAllInterfaces(interfaceIds),
                IUpgradeChecker.UpgradeChecker__InvalidImplementation()
            );
        }
    }
    
}