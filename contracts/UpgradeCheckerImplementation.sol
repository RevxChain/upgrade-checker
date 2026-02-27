// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {InterfaceIdsRegistry} from "./libraries/InterfaceIdsRegistry.sol";
import {IUpgradeChecker} from "./interfaces/IUpgradeChecker.sol";

abstract contract UpgradeCheckerImplementation is IUpgradeChecker, ERC165Upgradeable {

    function contractName() public view virtual returns(string memory thisContractName);

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns(bool supported) {
        return interfaceId == type(IUpgradeChecker).interfaceId || super.supportsInterface(interfaceId);
    }

}