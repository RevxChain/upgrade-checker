# Upgrade Checker

<div align="center">

A Solidity library for validating proxy contract upgrades with runtime integrity checks supporting various proxy patterns.

[![Ethereum](https://img.shields.io/badge/Ethereum-Compatible-blue?logo=ethereum)](https://ethereum.org)
[![Solidity](https://img.shields.io/badge/Solidity-^0.8.26-blue?logo=solidity)](https://soliditylang.org)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-5.6.0-blueviolet)](https://github.com/OpenZeppelin/openzeppelin-contracts)
[![Hardhat](https://img.shields.io/badge/Hardhat-Toolkit-yellow?logo=hardhat)](https://hardhat.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/RevxChain/upgrade-checker/.github%2Fworkflows%2Ftests.yml)](https://github.com/RevxChain/upgrade-checker/actions)

</div>

---

## Table of Contents
- [Overview](#overview)
- [Main Features](#main-features)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [Key Components](#key-components)
- [Quick Start](#quick-start)
- [License](#license)
- [Contributing](#сontributing)
- [Support](#support)

---

## Overview

**Upgrade Checker** is a production-ready Solidity library that provides robust, onchain validation mechanisms for proxy contract upgrades. It prevents upgrading the proxy to invalid implementations by enforcing strict contract verification rules at upgrade time.

---

## Main Features

### 1. **Various proxy pattern support**
- [**Beacon Proxy**](https://rareskills.io/post/beacon-proxy) - Beacon-controlled upgrades
- [**Transparent Upgradeable Proxy**](https://rareskills.io/post/transparent-upgradeable-proxy) - Proxy-controlled upgrades
- [**UUPS Proxy**](https://rareskills.io/post/uups-proxy) - Implementation-controlled upgrades

### 2. **Dual validation strategy**
- **Contract Name Matching** - Verify implementation identity via unique `contractName()`
- [**ERC165 Interface Checking**](https://eips.ethereum.org/EIPS/eip-165) - Required interfaceIds validation (optional)

### 3. **Persistent registry system**
- [**ERC7201 Namespaced Storage**](https://eips.ethereum.org/EIPS/eip-7201) - Avoid storage collisions
- **Dynamic Configuration** - Add/remove interfaceIds requirements at runtime
- **Interface Check Toggle** - Enable/disable validation as needed

### 4. **Developer-friendly**
- Copy-paste ready examples for each upgradeable proxy pattern (Diamond TBA)
- Comprehensive test suite with 50+ test cases
- Clear error messages and documentation

---

## Installation

### Repository 

#### Prerequisites
- **Node.js** 18.0.0 or later
- **npm** or **yarn** package manager
- **Git** for version control

#### Step 1: Clone the repository

```bash
git clone https://github.com/RevxChain/upgrade-checker.git
cd upgrade-checker
```

#### Step 2: Install dependencies

```bash
npm install
```

This installs:
- **Hardhat** - Ethereum development framework
- **OpenZeppelin Contracts** - Audited smart contract library
- **Hardhat Plugins** - Testing, upgrades, gas reporting, sizing

#### Step 3: Create environment file (optional)

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# PRIVATE KEYS
PRIVATE_KEY = your_private_key_here

# MAINNET FORK TEST
FORK_RPC_URL = https://eth.llamarpc.com
FORK_BLOCK_NUMBER = 24540000

# RPC URLS
ETH_RPC_URL = https://eth.llamarpc.com
BSC_RPC_URL = https://binance.llamarpc.com
ARBITRUM_RPC_URL = https://arbitrum.llamarpc.com
POLYGON_RPC_URL = https://polygon.llamarpc.com
BASE_RPC_URL = https://base.llamarpc.com

```

#### Step 4: Compile contracts

```bash
npx hardhat compile
```

Compiles all Solidity contracts and generates artifacts.

#### Step 5: Run tests

```bash
npx hardhat test
```

#### Step 6: Run coverage

```bash
npx hardhat coverage
```

#### Step 7: Run tests forking desired mainnet

Edit `.env` with your configuration:

```env
# MAINNET FORK TEST
FORK_RPC_URL=https://eth.llamarpc.com
FORK_BLOCK_NUMBER=24540000
```

Launch a local fork of the network in the first CLI:

```bash
npx hardhat node
```

Run tests in the second CLI:

```bash
npx hardhat test --network localhost
```

### Package

TBA

---

## Project Structure

```
upgrade-checker/
├── contracts/                                   # Smart contract source code
│   │                                 
│   ├── UpgradeChecker.sol                       # Core abstract checker (proxy side)
│   ├── UpgradeCheckerImplementation.sol         # Core abstract implementation (implementation side)
│   ├── interfaces/
│   │   └── IUpgradeChecker.sol                  # Interface specification
│   ├── libraries/
│   │   └── InterfaceIdsRegistry.sol             # ERC165 interfaceIds registry (proxy side)
│   ├── beacon/
│   │   ├── BeaconUpgradeChecker.sol             # Beacon checker (proxy side)
│   │   └── BeaconUpgradeCheckerExample.sol      # Beacon example
│   ├── transparent/
│   │   ├── TransparentUpgradeChecker.sol        # Transparent checker (proxy side)
│   │   └── TransparentUpgradeCheckerExample.sol # Transparent example
│   ├── uups/
│   │   ├── UUPSUpgradeChecker.sol               # UUPS checker (combined)
│   │   └── UUPSUpgradeCheckerExample.sol        # UUPS example
│   ├── proxies/
│   │   └── Proxies.sol                          # Proxy imports
│   └── mocks/
│       ├── InvalidImplementations.sol           # Test implementations
│       ├── InterfaceIdsRegistryMock.sol         # InterfaceIdsRegistry mock
│       └── TransparentUpgradeCheckerMock.sol    # TransparentUpgradeChecker mock
│
├── test/                                        
│   ├── BeaconUpgradeChecker.js                  # Beacon tests
│   ├── TransparentUpgradeChecker.js             # Transparent tests
│   ├── UUPSUpgradeChecker.js                    # UUPS tests
│   ├── InterfaceIdsRegistry.js                  # InterfaceIdsRegistry tests
│   └── UpgradeCheckerFixture.js                 # Test fixture
│
├── artifacts/                                   # Compiled contract artifacts
├── coverage/                                    # Code coverage reports
├── ignition/                                    # Hardhat Ignition deployment modules
├── hardhat.config.js                            # Hardhat configuration
├── package.json                                 # Dependencies and package info
├── slither.config.json                          # Slither analyzer config
└── README.md                                    # This file
```

---

## Key Components

### 1. **UpgradeChecker** (Proxy-side base contract)

Abstract contract providing validation logic for proxy contracts.

**Key functions:**
- `_checkContractName(address impl)` - Verify implementation name via staticcall
- `_checkInterfaces(address impl, bytes4[] memory ids)` - Validate ERC165 interface ids supporting
- `_checkOverall(address impl, bytes4[] memory ids)` - Execute both checks
- `_targetContractName()` - Returns expected implementation name (must override)

> [!TIP]
> If `ERC165` interface validation is not required, use the `_checkContractName()` or `_checkContractNameBeforeFallback()` functions only. In this case, there is no need for the `InterfaceIdsRegistry` library.

### 2. **UpgradeCheckerImplementation** (Implementation-side base contract)

Abstract contract for upgrade-safe implementations.

**Requirements:**
- Must override `contractName()` to return a unique identifier
- Must override `supportsInterface()` to declare supported interfaces

> [!WARNING]
> If interface checking is enabled and the `_checkOverall()` or `_checkInterfaces()` functions are used for validating, `supportsInterface()` MUST support all interfaces listed in `InterfaceIdsRegistry.getInterfaceIds()` of the proxy contract, along with `IUpgradeChecker` and `IERC165` interfaces by default.

### 3. **InterfaceIdsRegistry** (Storage library)

Manages persistent configuration using ERC7201 namespaced storage.

**Key functions:**
- `setInterfaceId(bytes4 id, bool add)` - Register/unregister required interface (access restriction required)
- `getInterfaceIds()` - Returns all registered interfaces
- `enableInterfacesCheck(bool enable)` - Toggle validation on/off (access restriction required)
- `getInterfacesCheckEnabled()` - Returns current validation state

**Storage location:** `0xb3567140b780d0e6eae18a93d996909c6c854e99daead678dce9f5547099f300`

> [!WARNING]
> The storage used for `InterfaceIdsRegistry` MUST always be located in the proxy contract. Calls to the library's setter functions MUST be made in the context of the proxy contract. The logic can be located in the implementation, depending on the proxy pattern.

### 4. **Pattern-specific implementations**

#### BeaconUpgradeChecker
- `constructor` performs initial validation
- The validation function must be added to the `upgradeTo()` function

#### TransparentUpgradeChecker
- `constructor` performs initial validation
- Detects upgrade calls via `msg.sender == ERC1967Utils.getAdmin()` and `msg.sig == ITransparentUpgradeableProxy.upgradeToAndCall.selector`
- Provides `_checkOverallBeforeFallback()`, `_checkContractNameBeforeFallback()`, `_checkInterfacesBeforeFallback()`
- The `*BeforeFallback()` validation function must be added to the `_fallback()` function

> [!WARNING]
> The default `TransparentUpgradeChecker` implementation is configured for use with the `OpenZeppelin` implementation of [`TransparentUpgradeableProxy`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.6/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L62) using [ERC1967](https://eips.ethereum.org/EIPS/eip-1967) and [ITransparentUpgradeableProxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v5.6/contracts/proxy/transparent/TransparentUpgradeableProxy.sol#L17) interface. For other implementations, you MUST override the [`_detectUpgradeCall()`](https://github.com/RevxChain/upgrade-checker/blob/main/contracts/transparent/TransparentUpgradeChecker.sol#L34) function and add custom logic for detecting upgrade calls and a desired validation function call.

#### UUPSUpgradeChecker
- Combines the checker with the implementation logic (following the `UUPS` pattern)
- The validation function must be added to the `_authorizeUpgrade()` function

---

## Quick Start

### Example: UpgradeableBeacon with Upgrade Checker

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

import {UpgradeCheckerImplementation} from "@revxchain/upgrade-checker/UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "@revxchain/upgrade-checker/libraries/InterfaceIdsRegistry.sol";
import {BeaconUpgradeChecker} from "@revxchain/upgrade-checker/beacon/BeaconUpgradeChecker.sol";

// Your beacon contract that manages upgrade, must inherit from {BeaconUpgradeChecker}
contract MyBeacon is UpgradeableBeacon, BeaconUpgradeChecker {

    constructor(
        address implementation, 
        address initialOwner
    ) BeaconUpgradeChecker(implementation) UpgradeableBeacon(implementation, initialOwner) {
        // Add optional {interfaceIds} setter and interfaces validation during deploy
        InterfaceIdsRegistry.setInterfaceId(type(IMyUpgradeable).interfaceId, true);
        _checkInterfaces(implementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    Override {upgradeTo} to add upgrade validation
    function upgradeTo(address newImplementation) public override onlyOwner() {
        // Validation runs here - upgrade fails if checks don't pass
        _checkOverall(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
        super.upgradeTo(newImplementation);
    }

    // Override {_targetContractName} to assign required implementation's {contractName}
    function _targetContractName() internal view virtual override returns(string memory targetContractName) {
        return "MyBeaconImplementation";
    }

    // Add {InterfaceIdsRegistry} functions to manage required interface Ids
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
}

// Your implementation must inherit from {UpgradeCheckerImplementation}
contract MyBeaconImplementation is UpgradeCheckerImplementation {

    // Override {contractName} to match beacon's {_targetContractName}
    function contractName() public pure override returns(string memory) {
        return "MyBeaconImplementation";
    }

    // Override {supportsInterface} to follow default {IERC165} rules
    function supportsInterface(bytes4 interfaceId) public view virtual override returns(bool) {
        return interfaceId == type(IMyUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
}

```

### Example: TransparentUpgradeableProxy with Upgrade Checker

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

import {TransparentUpgradeChecker} from "@revxchain/upgrade-checker/transparent/TransparentUpgradeChecker.sol";
import {UpgradeCheckerImplementation} from "@revxchain/upgrade-checker/UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "@revxchain/upgrade-checker/libraries/InterfaceIdsRegistry.sol";

// Your transparent proxy contract must inherit from {TransparentUpgradeChecker}
contract MyTransparentProxy is TransparentUpgradeChecker, TransparentUpgradeableProxy {

    constructor(
        address newImplementation, 
        address initialOwner, 
        bytes memory data
    ) TransparentUpgradeChecker(newImplementation) TransparentUpgradeableProxy(newImplementation, initialOwner, data) {
        // Add optional {interfaceIds} setter and interfaces validation during deploy
        InterfaceIdsRegistry.setInterfaceId(type(IAccessControl).interfaceId, true);
        _checkInterfaces(newImplementation, InterfaceIdsRegistry.getInterfaceIds());
    }

    // Override {_targetContractName} to assign required implementation's {contractName}
    function _targetContractName() internal pure override returns(string memory targetContractName) {
        return "MyTransparentImplementation";
    }

    // Override {_fallback} to add upgrade validation
    function _fallback() internal override {
        _checkOverallBeforeFallback();
        super._fallback();
    }
}

// Your implementation must inherit from {UpgradeCheckerImplementation}
contract MyTransparentImplementation is UpgradeCheckerImplementation, AccessControlUpgradeable {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) external initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    // Override {contractName} to match proxy's {_targetContractName}
    function contractName() public pure override returns(string memory) {
        return "MyTransparentImplementation";
    }

    // Override {supportsInterface} to follow default {IERC165} rules
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControlUpgradeable, UpgradeCheckerImplementation) returns(bool) {
        return 
            UpgradeCheckerImplementation.supportsInterface(interfaceId) || 
            AccessControlUpgradeable.supportsInterface(interfaceId);
    }

    // Add {InterfaceIdsRegistry} functions to manage required interface Ids
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
}
```

### Example: UUPS with Upgrade Checker

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

import {UpgradeCheckerImplementation} from "@revxchain/upgrade-checker/UpgradeCheckerImplementation.sol";
import {InterfaceIdsRegistry} from "@revxchain/upgrade-checker/libraries/InterfaceIdsRegistry.sol";
import {UUPSUpgradeChecker} from "@revxchain/upgrade-checker/uups/UUPSUpgradeChecker.sol";

// Your UUPS implementation must inherit from {UUPSUpgradeChecker}
contract MyUUPSImplementation is AccessControlUpgradeable, UUPSUpgradeChecker, UUPSUpgradeable {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) external initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    // Override {contractName} to return a unique identifier
    function contractName() public pure override returns(string memory) {
        return "MyUUPSImplementation";
    }

    // Override {supportsInterface} to follow default {IERC165} rules
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AccessControlUpgradeableUpgradeCheckerImplementation) returns(bool) {
        return 
            AccessControlUpgradeable.supportsInterface(interfaceId) || 
            UpgradeCheckerImplementation.supportsInterface(interfaceId);
    }

    // Add {InterfaceIdsRegistry} functions to manage interfaces
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

    // Override {_authorizeUpgrade} to add upgrade validation and authorization
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(DEFAULT_ADMIN_ROLE) {
        _checkOverall(newImplementation, InterfaceIdsRegistry.getInterfaceIds());

        // You can hardcode the required interfaces if {InterfaceIdsRegistry} management is unnecessary.
        // This may be changed in the next upgrade. Not recommended for use with other proxy patterns.
        //
        // bytes4[] memory _interfaceIds = new bytes4[](1);
        // _interfaceIds[0] = type(IAccessControl).interfaceId;
        // _checkOverall(newImplementation, _interfaceIds);
    }
}
```

---

## License

MIT License

Permission is hereby granted to use, copy, modify, and distribute this software freely.

See [LICENSE](LICENSE) file for full terms.

---

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

---

## Support

- [**GitHub Issues**](https://github.com/RevxChain/upgrade-checker/issues) - Report bugs