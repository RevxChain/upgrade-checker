const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { UpgradeCheckerFixture } = require("./UpgradeCheckerFixture.js");
const { expect } = require("chai");

describe("UUPS", function () {
    describe("Deploy", function () {
        it("After deploy state", async function () {
            const { admin, UUPS, UUPS_TWO } = await loadFixture(UpgradeCheckerFixture);

            expect(await UUPS.hasRole(await UUPS.DEFAULT_ADMIN_ROLE(), admin)).to.equal(true);
            expect(await UUPS.contractName()).to.equal("UUPSUpgradeCheckerExample");
            expect(await UUPS.getInterfacesCheckEnabled()).to.equal(true);

            expect(await UUPS.supportsInterface("0x01ffc9a7")).to.equal(true);
            expect(await UUPS.supportsInterface("0x75d0c0dc")).to.equal(true);
            expect(await UUPS.supportsInterface("0x7965db0b")).to.equal(true);

            expect(await UUPS_TWO.hasRole(await UUPS.DEFAULT_ADMIN_ROLE(), admin)).to.equal(true);
            expect(await UUPS_TWO.contractName()).to.equal("UUPSUpgradeCheckerExample");
            expect(await UUPS_TWO.getInterfacesCheckEnabled()).to.equal(true);
            expect(await UUPS_TWO.getInterfaceIds()).to.eql([]);

            expect(await UUPS_TWO.supportsInterface("0x01ffc9a7")).to.equal(true);
            expect(await UUPS_TWO.supportsInterface("0x75d0c0dc")).to.equal(true);
            expect(await UUPS_TWO.supportsInterface("0x7965db0b")).to.equal(true);
        });
    });

    describe("upgradeToAndCall()", function () {
        it("UpgradeChecker__InvalidImplementation: missing contractName()", async function () {
            const { admin, UUPS, beacon } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                beacon.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");

            await expect(UUPS.connect(admin).upgradeToAndCall(
                admin.address,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: incorrect contractName()", async function () {
            const { admin, UUPS, invalidImplIncorrectName } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                invalidImplIncorrectName.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing supportsInterface()", async function () {
            const { admin, UUPS, UUPSInvalidImplNoSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplNoSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing supported interfaces", async function () {
            const { admin, UUPS, UUPSInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing IERC165.interfaceId", async function () {
            const { admin, UUPS, UUPSInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x75d0c0dc", true);
            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x7965db0b", true);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing IUpgradeChecker.interfaceId", async function () {
            const { admin, UUPS, UUPSInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);
            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x7965db0b", true);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing IAccessControl.interfaceId", async function () {
            const { admin, UUPS, UUPSInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);
            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x75d0c0dc", true);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing new interfaceId", async function () {
            const { admin, UUPS_TWO, UUPSInvalidImplSupportedInterfaces, UUPSUpgradeCheckerExampleImplTwo } = await loadFixture(UpgradeCheckerFixture);

            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);
            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x75d0c0dc", true);
            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x7965db0b", true);

            await expect(UUPS_TWO.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.emit(UUPS_TWO, "Upgraded").withArgs(
                UUPSInvalidImplSupportedInterfaces.target
            );

            await expect(UUPS_TWO.connect(admin).upgradeToAndCall(
                UUPSUpgradeCheckerExampleImplTwo.target,
                "0x"
            )).to.emit(UUPS_TWO, "Upgraded").withArgs(
                UUPSUpgradeCheckerExampleImplTwo.target
            );

            await UUPS_TWO.connect(admin).setInterfaceId("0xffff0000", true);

            await expect(UUPS_TWO.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS_TWO, "UpgradeChecker__InvalidImplementation");
        });

        it("Success with default interfaceIds", async function () {
            const { admin, UUPS, UUPSInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);
            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x75d0c0dc", true);
            await UUPSInvalidImplSupportedInterfaces.setInterfaceId("0x7965db0b", true);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.emit(UUPS, "Upgraded").withArgs(
                UUPSInvalidImplSupportedInterfaces.target
            );
        });

        it("Success with disabled interfaces check", async function () {
            const { admin, UUPS, UUPS_TWO, UUPSInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "UpgradeChecker__InvalidImplementation");

            await UUPS.connect(admin).enableInterfacesCheck(false);

            expect(await UUPS.getInterfacesCheckEnabled()).to.equal(false);

            await expect(UUPS.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.emit(UUPS, "Upgraded").withArgs(
                UUPSInvalidImplSupportedInterfaces.target
            );

            await UUPS_TWO.connect(admin).setInterfaceId("0xffff0000", true);

            await expect(UUPS_TWO.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.be.revertedWithCustomError(UUPS_TWO, "UpgradeChecker__InvalidImplementation");

            await UUPS_TWO.connect(admin).enableInterfacesCheck(false);

            expect(await UUPS_TWO.getInterfacesCheckEnabled()).to.equal(false);

            await expect(UUPS_TWO.connect(admin).upgradeToAndCall(
                UUPSInvalidImplSupportedInterfaces.target,
                "0x"
            )).to.emit(UUPS_TWO, "Upgraded").withArgs(
                UUPSInvalidImplSupportedInterfaces.target
            );
        });
    });

    describe("onlyRole()", function () {
        it("enableInterfacesCheck()", async function () {
            const { user, UUPS, UUPS_TWO } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(user).enableInterfacesCheck(
                true
            )).to.be.revertedWithCustomError(UUPS, "AccessControlUnauthorizedAccount");

            await expect(UUPS_TWO.connect(user).enableInterfacesCheck(
                true
            )).to.be.revertedWithCustomError(UUPS_TWO, "AccessControlUnauthorizedAccount");
        });

        it("setInterfaceId()", async function () {
            const { user, UUPS_TWO } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS_TWO.connect(user).setInterfaceId(
                "0xffffffff",
                true
            )).to.be.revertedWithCustomError(UUPS_TWO, "AccessControlUnauthorizedAccount");
        });

        it("upgradeToAndCall()", async function () {
            const { user, UUPS, UUPS_TWO } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(user).upgradeToAndCall(
                user.address,
                "0x"
            )).to.be.revertedWithCustomError(UUPS, "AccessControlUnauthorizedAccount");

            await expect(UUPS_TWO.connect(user).upgradeToAndCall(
                user.address,
                "0x"
            )).to.be.revertedWithCustomError(UUPS_TWO, "AccessControlUnauthorizedAccount");
        });

        it("initialize()", async function () {
            const { user, UUPS, UUPS_TWO } = await loadFixture(UpgradeCheckerFixture);

            await expect(UUPS.connect(user).initialize(
                user.address
            )).to.be.revertedWithCustomError(UUPS, "InvalidInitialization");

            await expect(UUPS_TWO.connect(user).initialize(
                user.address
            )).to.be.revertedWithCustomError(UUPS_TWO, "InvalidInitialization");
        });
    });
});