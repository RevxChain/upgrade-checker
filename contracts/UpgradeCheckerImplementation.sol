// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {InterfaceIdsRegistry} from "./libraries/InterfaceIdsRegistry.sol";
import {IUpgradeChecker} from "./interfaces/IUpgradeChecker.sol";

/**
 * @title UpgradeCheckerImplementation
 * @notice Abstract base contract for upgrade-safe implementations with ERC165 support.
 * @dev Provides the implementation-side interface for {IUpgradeChecker} and ERC165 compliance.
 *      This contract must be inherited by all implementations to enable upgrade validation.
 *      Implementations must override {contractName} to return a unique identifier string.
 */
abstract contract UpgradeCheckerImplementation is IUpgradeChecker, ERC165Upgradeable {

    /**
     * @notice Returns the contract name for upgrade validation.
     * @dev Must be overridden in concrete implementations to return a unique name string
     *      that matches the proxy's {UpgradeChecker._targetContractName} expectation.
     * @return thisContractName The unique contract identifier string.
     */
    function contractName() public view virtual returns(string memory thisContractName);

    /**
     * @notice Declares support for {IUpgradeChecker} interface and delegates other checks.
     * @dev Overrides both {ERC165Upgradeable} and {IERC165} to declare support for
     *      {IUpgradeChecker}. Any additional interface support must be added by concrete
     *      implementations through override and super calls.
     * @param interfaceId The 4-byte interface selector to check for support.
     * @return supported {true} if {interfaceId} is {IUpgradeChecker} or supported by parent, {false} otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns(bool supported) {
        return interfaceId == type(IUpgradeChecker).interfaceId || super.supportsInterface(interfaceId);
    }

}