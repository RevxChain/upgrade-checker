const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { UpgradeCheckerFixture } = require("./UpgradeCheckerFixture.js");
const { expect } = require("chai");

describe("Beacon", function () {
    describe("Deploy", function () {
        it("UpgradeChecker__InvalidImplementation: incorrect contractName() during deploy", async function () {
            const { admin, invalidImplIncorrectName } = await loadFixture(UpgradeCheckerFixture);

            const BeaconUpgradeCheckerExample = await ethers.getContractFactory("BeaconUpgradeCheckerExample", admin);

            await expect(BeaconUpgradeCheckerExample.deploy(
                invalidImplIncorrectName.target,
                admin.address
            )).to.be.revertedWithCustomError(BeaconUpgradeCheckerExample, "UpgradeChecker__InvalidImplementation");
        });

        it("After deploy state", async function () {
            const { admin, implementationForBeacon, beacon, beaconProxy } = await loadFixture(UpgradeCheckerFixture);

            expect(await beacon.implementation()).to.equal(implementationForBeacon.target);
            expect(await beacon.owner()).to.equal(admin.address);
            expect(await beacon.getInterfacesCheckEnabled()).to.equal(true);
            expect(await beacon.getInterfaceIds()).to.eql([]);

            expect(await beaconProxy.contractName()).to.equal("ImplementationForBeacon");
            expect(await beaconProxy.supportsInterface("0x01ffc9a7")).to.equal(true);
            expect(await beaconProxy.supportsInterface("0x75d0c0dc")).to.equal(true);
        });
    });

    describe("upgradeTo()", function () {
        it("UpgradeChecker__InvalidImplementation: missing contractName()", async function () {
            const { admin, beacon } = await loadFixture(UpgradeCheckerFixture);

            await expect(beacon.connect(admin).upgradeTo(
                beacon.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");

            await expect(beacon.connect(admin).upgradeTo(
                admin.address
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: incorrect contractName()", async function () {
            const { admin, beacon, invalidImplIncorrectName } = await loadFixture(UpgradeCheckerFixture);

            await expect(beacon.connect(admin).upgradeTo(
                invalidImplIncorrectName.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing supportsInterface()", async function () {
            const { admin, beacon, beaconInvalidImplNoSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplNoSupportedInterfaces.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing supported interfaces", async function () {
            const { admin, beacon, beaconInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing IUpgradeChecker.interfaceId", async function () {
            const { admin, beacon, beaconInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await beaconInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");
        });

        it("UpgradeChecker__InvalidImplementation: missing new interfaceId", async function () {
            const { admin, beacon, beaconInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await beaconInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);
            await beaconInvalidImplSupportedInterfaces.setInterfaceId("0x75d0c0dc", true);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.emit(beacon, "Upgraded").withArgs(
                beaconInvalidImplSupportedInterfaces.target
            );

            expect(await beacon.implementation()).to.equal(beaconInvalidImplSupportedInterfaces.target);

            await beacon.connect(admin).setInterfaceId("0xffff0000", true);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");
        });

        it("Success with default interfaceIds", async function () {
            const { admin, beacon, beaconInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await beaconInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);
            await beaconInvalidImplSupportedInterfaces.setInterfaceId("0x75d0c0dc", true);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.emit(beacon, "Upgraded").withArgs(
                beaconInvalidImplSupportedInterfaces.target
            );
        });

        it("Success with disabled interfaces check", async function () {
            const { admin, beacon, beaconInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");

            await beacon.connect(admin).enableInterfacesCheck(false);

            expect(await beacon.getInterfacesCheckEnabled()).to.equal(false);
            expect(await beacon.getInterfaceIds()).to.eql([]);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.emit(beacon, "Upgraded").withArgs(
                beaconInvalidImplSupportedInterfaces.target
            );

            await beacon.setInterfaceId("0x01ffc9a7", true);
            await beacon.setInterfaceId("0x75d0c0dc", true);

            expect(await beacon.getInterfacesCheckEnabled()).to.equal(false);
            expect(await beacon.getInterfaceIds()).to.eql(["0x01ffc9a7", "0x75d0c0dc"]);

            await beacon.connect(admin).enableInterfacesCheck(true);

            expect(await beacon.getInterfacesCheckEnabled()).to.equal(true);
            expect(await beacon.getInterfaceIds()).to.eql(["0x01ffc9a7", "0x75d0c0dc"]);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.be.revertedWithCustomError(beacon, "UpgradeChecker__InvalidImplementation");

            await beacon.connect(admin).enableInterfacesCheck(false);

            expect(await beacon.getInterfacesCheckEnabled()).to.equal(false);
            expect(await beacon.getInterfaceIds()).to.eql(["0x01ffc9a7", "0x75d0c0dc"]);

            await expect(beacon.connect(admin).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.emit(beacon, "Upgraded").withArgs(
                beaconInvalidImplSupportedInterfaces.target
            );
        });
    });

    describe("onlyOwner()", function () {
        it("enableInterfacesCheck()", async function () {
            const { user, beacon } = await loadFixture(UpgradeCheckerFixture);

            await expect(beacon.connect(user).enableInterfacesCheck(
                true
            )).to.be.revertedWithCustomError(beacon, "OwnableUnauthorizedAccount");
        });

        it("setInterfaceId()", async function () {
            const { user, beacon } = await loadFixture(UpgradeCheckerFixture);

            await expect(beacon.connect(user).setInterfaceId(
                "0x01ffc9a7",
                true
            )).to.be.revertedWithCustomError(beacon, "OwnableUnauthorizedAccount");
        });

        it("upgradeTo()", async function () {
            const { user, beacon, beaconInvalidImplSupportedInterfaces } = await loadFixture(UpgradeCheckerFixture);

            await beaconInvalidImplSupportedInterfaces.setInterfaceId("0x01ffc9a7", true);
            await beaconInvalidImplSupportedInterfaces.setInterfaceId("0x75d0c0dc", true);

            await expect(beacon.connect(user).upgradeTo(
                beaconInvalidImplSupportedInterfaces.target
            )).to.be.revertedWithCustomError(beacon, "OwnableUnauthorizedAccount");
        });
    });
});