const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { UpgradeCheckerFixture } = require("./UpgradeCheckerFixture.js");
const { expect } = require("chai");

describe("Transparent", function () {
    describe("Deploy", function () {
        it("UpgradeChecker__InvalidImplementation: incorrect contractName() during deploy", async function () {
            const { admin, transparentInvalidImplNoSupportedInterfaces, initCalldata, invalidImplIncorrectName } = await loadFixture(UpgradeCheckerFixture);

            const TransparentUpgradeCheckerExample = await ethers.getContractFactory("TransparentUpgradeCheckerExample", admin);

            await expect(TransparentUpgradeCheckerExample.deploy(
                invalidImplIncorrectName.target,
                admin.address,
                initCalldata
            )).to.be.revertedWithCustomError(TransparentUpgradeCheckerExample, "UpgradeChecker__InvalidImplementation");

            await expect(TransparentUpgradeCheckerExample.deploy(
                transparentInvalidImplNoSupportedInterfaces.target,
                admin.address,
                initCalldata
            )).to.be.revertedWithCustomError(TransparentUpgradeCheckerExample, "UpgradeChecker__InvalidImplementation");
        });

        it("After deploy state", async function () {
            const { admin, transparent, transparentCheckContract, proxyAdmin, implementationForTransparent } = await loadFixture(UpgradeCheckerFixture);

            expect(await transparent.hasRole(await transparent.DEFAULT_ADMIN_ROLE(), admin)).to.equal(true);
            expect(await transparent.contractName()).to.equal("ImplementationForTransparent");
            expect(await transparent.getInterfacesCheckEnabled()).to.equal(true);
            expect(await transparent.getInterfaceIds()).to.eql(["0x7965db0b"]);

            expect(await transparentCheckContract.hasRole(await transparent.DEFAULT_ADMIN_ROLE(), admin)).to.equal(true);
            expect(await transparentCheckContract.contractName()).to.equal("ImplementationForTransparent");
            expect(await transparentCheckContract.getInterfacesCheckEnabled()).to.equal(true);
            expect(await transparentCheckContract.getInterfaceIds()).to.eql([]);

            expect(await transparent.supportsInterface("0x01ffc9a7")).to.equal(true);
            expect(await transparent.supportsInterface("0x75d0c0dc")).to.equal(true);
            expect(await transparent.supportsInterface("0x7965db0b")).to.equal(true);

            expect(await implementationForTransparent.supportsInterface("0x01ffc9a7")).to.equal(true);
            expect(await implementationForTransparent.supportsInterface("0x75d0c0dc")).to.equal(true);
            expect(await implementationForTransparent.supportsInterface("0x7965db0b")).to.equal(true);

            expect(await proxyAdmin.owner()).to.equal(admin.address);
            expect(await proxyAdmin.UPGRADE_INTERFACE_VERSION()).to.equal("5.0.0");
        });
    });

    describe("_fallback()", function () {
        it("UpgradeChecker__InvalidImplementation: missing contractName()", async function () {
            const {
                admin, proxyAdmin, transparent, beacon, proxyAdminCheckContract, transparentCheckContract, proxyAdminCheckInterfaces,
                transparentCheckInterfaces
            } = await loadFixture(UpgradeCheckerFixture);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                beacon.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                admin.address,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");

            await expect(proxyAdminCheckContract.connect(admin).upgradeAndCall(
                transparentCheckContract.target,
                beacon.target,
                "0x"
            )).to.be.revertedWithCustomError(transparentCheckContract, "UpgradeChecker__InvalidImplementation");

            await expect(proxyAdminCheckContract.connect(admin).upgradeAndCall(
                transparentCheckContract.target,
                admin.address,
                "0x"
            )).to.be.revertedWithCustomError(transparentCheckContract, "UpgradeChecker__InvalidImplementation");

            await expect(proxyAdminCheckInterfaces.connect(admin).upgradeAndCall(
                transparentCheckInterfaces.target,
                beacon.target,
                "0x"
            )).to.be.revertedWithCustomError(transparentCheckInterfaces, "UpgradeChecker__InvalidImplementation");

            await expect(proxyAdminCheckInterfaces.connect(admin).upgradeAndCall(
                transparentCheckInterfaces.target,
                admin.address,
                "0x"
            )).to.be.revertedWithCustomError(transparentCheckInterfaces, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: incorrect contractName()", async function () {
            const {
                admin, proxyAdmin, transparent, invalidImplIncorrectName, proxyAdminCheckContract, transparentCheckContract
            } = await loadFixture(UpgradeCheckerFixture);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                invalidImplIncorrectName.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");

            await expect(proxyAdminCheckContract.connect(admin).upgradeAndCall(
                transparentCheckContract.target,
                admin.address,
                "0x"
            )).to.be.revertedWithCustomError(transparentCheckContract, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing supportsInterface()", async function () {
            const {
                admin, proxyAdmin, transparent, transparentInvalidImplNoSupportedInterfaces, proxyAdminCheckContract, transparentCheckContract,
                transparentUpgradeCheckerMockCheckContract, proxyAdminCheckInterfaces, transparentCheckInterfaces,
                transparentUpgradeCheckerMockCheckInterfaces
            } = await loadFixture(UpgradeCheckerFixture);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplNoSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");

            await expect(proxyAdminCheckInterfaces.connect(admin).upgradeAndCall(
                transparentCheckInterfaces.target,
                transparentInvalidImplNoSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparentCheckInterfaces, "UpgradeChecker__InvalidImplementation");

            await transparentCheckContract.connect(admin).enableInterfacesCheck(true);
            await transparentCheckInterfaces.connect(admin).enableInterfacesCheck(false);

            await expect(proxyAdminCheckContract.connect(admin).upgradeAndCall(
                transparentCheckContract.target,
                transparentInvalidImplNoSupportedInterfaces.target,
                "0x"
            )).to.emit(transparentUpgradeCheckerMockCheckContract, "Upgraded").withArgs(
                transparentInvalidImplNoSupportedInterfaces.target
            );

            await expect(proxyAdminCheckInterfaces.connect(admin).upgradeAndCall(
                transparentCheckInterfaces.target,
                transparentInvalidImplNoSupportedInterfaces.target,
                "0x"
            )).to.emit(transparentUpgradeCheckerMockCheckInterfaces, "Upgraded").withArgs(
                transparentInvalidImplNoSupportedInterfaces.target
            );
        });

        it("UpgradeChecker__InvalidImplementation: missing supported interfaces", async function () {
            const { admin, proxyAdmin, transparent, transparentInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing IERC165.interfaceId", async function () {
            const { admin, proxyAdmin, transparent, transparentInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x75d0c0dc", true);
            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x7965db0b", true);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing IUpgradeChecker.interfaceId", async function () {
            const { admin, proxyAdmin, transparent, transparentInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x01ffc9a7", true);
            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x7965db0b", true);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing IAccessControl.interfaceId", async function () {
            const { admin, proxyAdmin, transparent, transparentInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x75d0c0dc", true);
            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x01ffc9a7", true);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing new interfaceId", async function () {
            const {
                admin, proxyAdmin, transparent, transparentUpgradeCheckerExampleProxy, transparentInvalidImplSupportedInterfaces
            } = await loadFixture(UpgradeCheckerFixture);

            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x01ffc9a7", true);
            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x75d0c0dc", true);
            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x7965db0b", true);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.emit(transparentUpgradeCheckerExampleProxy, "Upgraded").withArgs(
                transparentInvalidImplSupportedInterfaces.target
            );

            await transparent.connect(admin).setInterfaceId("0xffff0000", true);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");
        });

        it("Success with default interfaceIds", async function () {
            const {
                admin, proxyAdmin, transparent, transparentUpgradeCheckerExampleProxy, transparentInvalidImplSupportedInterfaces
            } = await loadFixture(UpgradeCheckerFixture);

            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x01ffc9a7", true);
            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x75d0c0dc", true);
            await transparentInvalidImplSupportedInterfaces.setInterfaceIdPure("0x7965db0b", true);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.emit(transparentUpgradeCheckerExampleProxy, "Upgraded").withArgs(
                transparentInvalidImplSupportedInterfaces.target
            );
        });

        it("Success with disabled interfaces check", async function () {
            const {
                admin, proxyAdmin, transparent, transparentUpgradeCheckerExampleProxy, transparentInvalidImplSupportedInterfaces
            } = await loadFixture(UpgradeCheckerFixture);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(transparent, "UpgradeChecker__InvalidImplementation");

            await transparent.connect(admin).enableInterfacesCheck(false);

            expect(await transparent.getInterfacesCheckEnabled()).to.equal(false);
            expect(await transparent.getInterfaceIds()).to.eql(["0x7965db0b"]);

            await expect(proxyAdmin.connect(admin).upgradeAndCall(
                transparent.target,
                transparentInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.emit(transparentUpgradeCheckerExampleProxy, "Upgraded").withArgs(
                transparentInvalidImplSupportedInterfaces.target
            );
        });
    });

    describe("onlyRole()", function () {
        it("setInterfaceId()", async function () {
            const { user, transparent } = await loadFixture(UpgradeCheckerFixture);

            await expect(transparent.connect(user).setInterfaceId(
                "0xffffffff",
                true
            )).to.be.revertedWithCustomError(transparent, "AccessControlUnauthorizedAccount");
        });

        it("enableInterfacesCheck()", async function () {
            const { user, transparent } = await loadFixture(UpgradeCheckerFixture);

            await expect(transparent.connect(user).enableInterfacesCheck(
                true
            )).to.be.revertedWithCustomError(transparent, "AccessControlUnauthorizedAccount");
        });

        it("initialize()", async function () {
            const { user, transparent } = await loadFixture(UpgradeCheckerFixture);

            await expect(transparent.connect(user).initialize(
                user.address
            )).to.be.revertedWithCustomError(transparent, "InvalidInitialization");
        });
    });
});