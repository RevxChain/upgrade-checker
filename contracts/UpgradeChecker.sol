// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import {InterfaceIdsRegistry} from "./libraries/InterfaceIdsRegistry.sol";
import {IUpgradeChecker} from "./interfaces/IUpgradeChecker.sol";

/**
 * @title UpgradeChecker
 * @notice Abstract base contract providing validation logic for proxy upgrades.
 * @dev Implements core upgrade validation through contract name verification and ERC165 interface checking.
 *      This contract is designed to be inherited by proxy contracts (Beacon, Transparent, UUPS)
 *      to enforce safety checks before accepting new implementations.
 */
abstract contract UpgradeChecker {
    using ERC165Checker for address;

    /**
     * @notice Returns the expected contract name for valid implementations.
     * @dev Must be overridden by concrete implementation to specify the target name.
     * @return targetContractName The required contract name string.
     */
    function _targetContractName() internal view virtual returns(string memory targetContractName);

    /**
     * @notice Performs comprehensive upgrade validation including name and interface checks.
     * @dev Calls both {_checkContractName} and {_checkInterfaces} sequentially.
     *      This is the main entry point for validating a new implementation.
     * @param newImplementation The address of the new implementation to validate.
     * @param interfaceIds Array of 4-byte interface IDs that the implementation must support.
     * @custom:reverts UpgradeChecker__InvalidImplementation if either check fails.
     */
    function _checkOverall(address newImplementation, bytes4[] memory interfaceIds) internal view virtual {
        _checkContractName(newImplementation);
        _checkInterfaces(newImplementation, interfaceIds);
    }

    /**
     * @notice Validates that the implementation has the correct contract name.
     * @dev Performs a staticcall to {contractName} on the implementation and compares
     *      the result to the value from {_targetContractName}.
     * @param newImplementation The address of the implementation contract to validate.
     * @custom:reverts UpgradeChecker__InvalidImplementation if:
     *        - The staticcall fails (no contract or function doesn't exist)
     *        - The returned name doesn't match {_targetContractName}
     */
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

    /**
     * @notice Validates that the implementation supports required ERC165 interfaces.
     * @dev Performs two checks when {InterfaceIdsRegistry.getInterfacesCheckEnabled} returns true:
     *      1. Implementation must support {IERC165} interface
     *      2. Implementation must support {IUpgradeChecker} interface
     *      3. Implementation must support all interfaces in the {interfaceIds} array
     *      If checks are disabled via registry, validation is skipped.
     * @param newImplementation The address of the implementation contract to validate.
     * @param interfaceIds Array of 4-byte interface selectors to check for support.
     * @custom:reverts UpgradeChecker__InvalidImplementation if:
     *        - Interface checks are enabled AND
     *        - Implementation doesn't support {IERC165} OR
     *        - Implementation doesn't support {IUpgradeChecker} OR
     *        - Implementation doesn't support at least one of interfaces in {interfaceIds}
     */
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