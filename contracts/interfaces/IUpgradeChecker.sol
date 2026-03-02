// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title IUpgradeChecker
 * @notice Interface defining the upgrade validation contract specification.
 * @dev Extends {IERC165} for interface introspection and defines the contract name function.
 */
interface IUpgradeChecker is IERC165 {

    /**
     * @notice Emitted when upgrade validation fails.
     * @dev This error is raised when an implementation doesn't meet upgrade requirements:
     *      - Invalid or missing {contractName} function
     *      - Incorrect contract name returned
     *      - Missing {supportsInterface} implementation
     *      - Required ERC165 interfaces not supported. {IUpgradeChecker} and {IERC165} by default.
     */
    error UpgradeChecker__InvalidImplementation();

    /**
     * @notice Returns the contract name for upgrade validation.
     * @dev This function is called via staticcall by {UpgradeChecker._checkContractName}
     *      to verify implementation identity. The returned string must exactly match
     *      the proxy's expected name (set via {UpgradeChecker._targetContractName}).
     * @return thisContractName The unique contract identifier string for this implementation.
     */
    function contractName() external view returns(string memory thisContractName);

}