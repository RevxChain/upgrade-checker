const { mine } = require("@nomicfoundation/hardhat-network-helpers");

const TransparentModule = require("../ignition/modules/TransparentModule");
const BeaconModule = require("../ignition/modules/BeaconModule");
const UUPSModule = require("../ignition/modules/UUPSModule");

async function UpgradeCheckerFixture() {
    await mine(1);

    const [admin, user] = await ethers.getSigners();

    const {
        implementationForBeacon,
        beacon,
        proxy,
        invalidImplIncorrectName,
        beaconInvalidImplNoSupportedInterfaces,
        beaconInvalidImplSupportedInterfaces
    } = await ignition.deploy(BeaconModule, {
        parameters: {
            BeaconModule: {
                initialOwner: admin.address
            },
        },
    });

    const beaconProxy = await ethers.getContractAt("ImplementationForBeacon", proxy.target);

    const initCalldata = ethers.id('initialize(address)').substring(0, 10) + ethers.zeroPadValue(admin.address, 32).slice(2);

    const {
        implementationForTransparent,
        transparentUpgradeCheckerExampleProxy,
        transparentUpgradeCheckerMockCheckContract,
        transparentUpgradeCheckerMockCheckInterfaces,
        transparentInvalidImplNoSupportedInterfaces,
        transparentInvalidImplSupportedInterfaces,
        transparent,
        transparentCheckContract,
        transparentCheckInterfaces
    } = await ignition.deploy(TransparentModule, {
        parameters: {
            TransparentModule: {
                initialOwner: admin.address,
                initCalldata: initCalldata
            },
        },
    });

    const proxyAdmin = await ethers.getContractAt("ProxyAdmin", ethers.getCreateAddress({ from: transparent.target, nonce: 1 }));
    const proxyAdminCheckContract = await ethers.getContractAt("ProxyAdmin", ethers.getCreateAddress({ from: transparentCheckContract.target, nonce: 1 }));
    const proxyAdminCheckInterfaces = await ethers.getContractAt("ProxyAdmin", ethers.getCreateAddress({ from: transparentCheckInterfaces.target, nonce: 1 }));

    const {
        UUPSUpgradeCheckerExampleImplTwo,
        UUPS,
        UUPS_TWO,
        UUPSInvalidImplNoSupportedInterfaces,
        UUPSInvalidImplSupportedInterfaces
    } = await ignition.deploy(UUPSModule, {
        parameters: {
            UUPSModule: {
                initCalldata: initCalldata
            },
        },
    });

    const InterfaceIdsRegistryMock = await ethers.getContractFactory("InterfaceIdsRegistryMock", admin);
    const registry = await InterfaceIdsRegistryMock.deploy();
    await registry.waitForDeployment();

    return {
        admin, user, implementationForBeacon, beacon, beaconProxy, invalidImplIncorrectName, beaconInvalidImplNoSupportedInterfaces, proxyAdminCheckInterfaces,
        beaconInvalidImplSupportedInterfaces, UUPSUpgradeCheckerExampleImplTwo, UUPS, UUPS_TWO, implementationForTransparent, transparent, proxyAdmin,
        transparentUpgradeCheckerExampleProxy, transparentInvalidImplNoSupportedInterfaces, transparentInvalidImplSupportedInterfaces, initCalldata,
        transparentCheckContract, proxyAdminCheckContract, transparentUpgradeCheckerMockCheckContract, transparentUpgradeCheckerMockCheckInterfaces,
        transparentCheckInterfaces, UUPSInvalidImplNoSupportedInterfaces, UUPSInvalidImplSupportedInterfaces, registry
    };
};

module.exports = { UpgradeCheckerFixture };