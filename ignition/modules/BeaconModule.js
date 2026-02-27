const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("BeaconModule", (m) => {

    const initialOwner = m.getParameter("initialOwner");

    const implementationForBeacon = m.contract("ImplementationForBeacon", []);

    const beacon = m.contract("BeaconUpgradeCheckerExample", [implementationForBeacon, initialOwner]);

    const proxy = m.contract('BeaconProxy', [beacon, "0x"]);

    const invalidImplIncorrectName = m.contract("InvalidImplementationIncorrectName", []);

    const beaconInvalidImplNoSupportedInterfaces = m.contract("BeaconInvalidImplementationNoSupportedInterfaces", []);

    const beaconInvalidImplSupportedInterfaces = m.contract("BeaconInvalidImplementationSupportedInterfaces", []);

    return { implementationForBeacon, beacon, proxy, invalidImplIncorrectName, beaconInvalidImplNoSupportedInterfaces, beaconInvalidImplSupportedInterfaces };
});