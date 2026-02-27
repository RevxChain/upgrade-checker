const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

async function InterfaceIdsRegistryFixture() {
    const [admin] = await ethers.getSigners();

    const InterfaceIdsRegistryMock = await ethers.getContractFactory("InterfaceIdsRegistryMock", admin);
    const registry = await InterfaceIdsRegistryMock.deploy();
    await registry.waitForDeployment();

    return { admin, registry };
};

describe("InterfaceIdsRegistry", function () {
    describe("Deploy", function () {
        it("After deploy state", async function () {
            const { registry } = await loadFixture(InterfaceIdsRegistryFixture);

            expect(await registry.getInterfacesCheckEnabled()).to.equal(true);
            expect(await registry.getInterfaceIds()).to.eql([]);
        });
    });

    describe("enableInterfacesCheck()", function () {
        it("Success", async function () {
            const { admin, registry } = await loadFixture(InterfaceIdsRegistryFixture);

            const INTERFACE_IDS_REGISTRY_STORAGE_LOCATION = "0xb3567140b780d0e6eae18a93d996909c6c854e99daead678dce9f5547099f300";

            expect(await registry.getInterfacesCheckEnabled()).to.equal(true);
            expect(await ethers.provider.getStorage(registry.target, INTERFACE_IDS_REGISTRY_STORAGE_LOCATION)).to.equal(ethers.ZeroHash);

            await expect(registry.connect(admin).enableInterfacesCheck(
                true
            )).to.emit(registry, "InterfacesCheckEnabled").withArgs(
                true
            );

            expect(await registry.getInterfacesCheckEnabled()).to.equal(true);

            await expect(registry.connect(admin).enableInterfacesCheck(
                false
            )).to.emit(registry, "InterfacesCheckEnabled").withArgs(
                false
            );

            expect(await registry.getInterfacesCheckEnabled()).to.equal(false);
            expect(await ethers.provider.getStorage(registry.target, INTERFACE_IDS_REGISTRY_STORAGE_LOCATION)).to.equal(ethers.ZeroHash.slice(0, -1) + 1n);

            await expect(registry.connect(admin).enableInterfacesCheck(
                false
            )).to.emit(registry, "InterfacesCheckEnabled").withArgs(
                false
            );

            expect(await registry.getInterfacesCheckEnabled()).to.equal(false);
            expect(await ethers.provider.getStorage(registry.target, INTERFACE_IDS_REGISTRY_STORAGE_LOCATION)).to.equal(ethers.ZeroHash.slice(0, -1) + 1n);

            await expect(registry.connect(admin).enableInterfacesCheck(
                true
            )).to.emit(registry, "InterfacesCheckEnabled").withArgs(
                true
            );

            expect(await registry.getInterfacesCheckEnabled()).to.equal(true);
            expect(await ethers.provider.getStorage(registry.target, INTERFACE_IDS_REGISTRY_STORAGE_LOCATION)).to.equal(ethers.ZeroHash);
        });
    });

    describe("setInterfaceId()", function () {
        it("InterfaceIdsRegistry__InvalidInterfaceId", async function () {
            const { admin, registry } = await loadFixture(InterfaceIdsRegistryFixture);

            await expect(registry.connect(admin).setInterfaceId(
                "0xffffffff",
                true
            )).to.be.revertedWithCustomError(registry, "InterfaceIdsRegistry__InvalidInterfaceId");

            await expect(registry.connect(admin).setInterfaceId(
                "0xffffffff",
                false
            )).to.be.revertedWithCustomError(registry, "InterfaceIdsRegistry__InvalidInterfaceId");
        });

        it("Success", async function () {
            const { admin, registry } = await loadFixture(InterfaceIdsRegistryFixture);

            expect(await registry.getInterfaceIds()).to.eql([]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000000",
                true
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000000",
                true
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000000"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000000",
                false
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000000",
                false
            );

            expect(await registry.getInterfaceIds()).to.eql([]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000000",
                true
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000000",
                true
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000000"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000001",
                true
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000001",
                true
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000000", "0x00000001"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000000",
                true
            )).to.not.emit(registry, "InterfaceIdSet");

            expect(await registry.getInterfaceIds()).to.eql(["0x00000000", "0x00000001"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000001",
                true
            )).to.not.emit(registry, "InterfaceIdSet");

            expect(await registry.getInterfaceIds()).to.eql(["0x00000000", "0x00000001"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000000",
                false
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000000",
                false
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000001"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000000",
                true
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000000",
                true
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000001", "0x00000000"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000002",
                true
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000002",
                true
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000001", "0x00000000", "0x00000002"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000003",
                false
            )).to.not.emit(registry, "InterfaceIdSet");

            expect(await registry.getInterfaceIds()).to.eql(["0x00000001", "0x00000000", "0x00000002"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000000",
                false
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000000",
                false
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000001", "0x00000002"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000002",
                false
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000002",
                false
            );

            expect(await registry.getInterfaceIds()).to.eql(["0x00000001"]);

            await expect(registry.connect(admin).setInterfaceId(
                "0x00000001",
                false
            )).to.emit(registry, "InterfaceIdSet").withArgs(
                "0x00000001",
                false
            );

            expect(await registry.getInterfaceIds()).to.eql([]);
        });
    });
});