const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("TransparentModule", (m) => {

    const initialOwner = m.getParameter("initialOwner");
    const initCalldata = m.getParameter("initCalldata");

    const implementationForTransparent = m.contract("ImplementationForTransparent", []);

    const transparentUpgradeCheckerExampleProxy = m.contract("TransparentUpgradeCheckerExample", [implementationForTransparent, initialOwner, initCalldata]);

    const transparentUpgradeCheckerMockCheckContract = m.contract("TransparentUpgradeCheckerMockCheckContract",
        [
            implementationForTransparent,
            initialOwner,
            initCalldata
        ]
    );

    const transparentUpgradeCheckerMockCheckInterfaces = m.contract("TransparentUpgradeCheckerMockCheckInterfaces",
        [
            implementationForTransparent,
            initialOwner,
            initCalldata
        ]
    );

    const transparentInvalidImplNoSupportedInterfaces = m.contract("TransparentInvalidImplementationNoSupportedInterfaces", []);

    const transparentInvalidImplSupportedInterfaces = m.contract("TransparentInvalidImplementationSupportedInterfaces", []);

    const transparent = m.contractAt("ImplementationForTransparent", transparentUpgradeCheckerExampleProxy, { id: "transparent" });

    const transparentCheckContract = m.contractAt("ImplementationForTransparent", transparentUpgradeCheckerMockCheckContract, { id: "transparentCheckContract" });

    const transparentCheckInterfaces = m.contractAt("ImplementationForTransparent", transparentUpgradeCheckerMockCheckInterfaces, { id: "transparentCheckInterfaces" });

    return {
        implementationForTransparent, transparentUpgradeCheckerExampleProxy, transparentUpgradeCheckerMockCheckContract, transparentUpgradeCheckerMockCheckInterfaces,
        transparentInvalidImplNoSupportedInterfaces, transparentInvalidImplSupportedInterfaces, transparent, transparentCheckContract, transparentCheckInterfaces
    };
});