// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IUpgradeChecker is IERC165 {

    error UpgradeChecker__InvalidImplementation();

    function contractName() external view returns(string memory thisContractName);

}