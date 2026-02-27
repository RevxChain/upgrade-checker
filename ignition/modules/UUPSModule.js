const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("UUPSModule", (m) => {

    const initCalldata = m.getParameter("initCalldata");

    const UUPSUpgradeCheckerExampleImpl = m.contract("UUPSUpgradeCheckerExample", []);

    const UUPSUpgradeCheckerExampleImplTwo = m.contract("UUPSUpgradeCheckerExampleTwo", []);

    const UUPSUpgradeCheckerExampleProxy = m.contract('ERC1967Proxy', [UUPSUpgradeCheckerExampleImpl, initCalldata], { id: "UUPS_proxy" });

    const UUPSUpgradeCheckerExampleProxyTwo = m.contract('ERC1967Proxy', [UUPSUpgradeCheckerExampleImplTwo, initCalldata], { id: "UUPS_TWO_proxy" });

    const UUPS = m.contractAt("UUPSUpgradeCheckerExample", UUPSUpgradeCheckerExampleProxy, { id: "UUPS" });

    const UUPS_TWO = m.contractAt("UUPSUpgradeCheckerExampleTwo", UUPSUpgradeCheckerExampleProxyTwo, { id: "UUPS_TWO" });

    const UUPSInvalidImplNoSupportedInterfaces = m.contract("UUPSInvalidImplementationNoSupportedInterfaces", []);

    const UUPSInvalidImplSupportedInterfaces = m.contract("UUPSInvalidImplementationSupportedInterfaces", []);

    return { UUPSUpgradeCheckerExampleImplTwo, UUPS, UUPS_TWO, UUPSInvalidImplNoSupportedInterfaces, UUPSInvalidImplSupportedInterfaces };
});