const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const MockSmartContractTest = artifacts.require("MockSmartContractTest");
const Verificator = artifacts.require("Verificator");

contract('SmartContractVerificator', (accounts) => {

    before(async () => {
        this.smartContractVerificatorInstance = await SmartContractVerificator.deployed();
        this.smartContractToVerify = await MockSmartContractToVerify.deployed();
        this.smartContractTest = await MockSmartContractTest.deployed();
        this.verificatorInstance = await Verificator.deployed();
    });

    it('should check smart contract to verify', async () => {
        assert.equal(await this.smartContractVerificatorInstance.getSmartContractToVerify(), this.smartContractToVerify.address, "Smart contract addresses should be equal.");
        assert(await this.smartContractVerificatorInstance.isSmartContractVerified() === false, "Smart contract should not be verified.");
        assert(await this.smartContractVerificatorInstance.getVerificationState() === "ACTIVE", "Smart contract should be active.");
    });

    it('should send smart contract test', async () => {
        const owner = accounts[0];
        await this.verificatorInstance.addVerifiedProgrammer(owner).then(async () => {
            assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
            try {
                // cause error because owner should not sent a test for his own contract
                await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: owner});
            } catch (e) {
                var err = e;
            }
            assert.isOk(err instanceof Error, "Transaction was not reverted although owner should not sent a test.");
        });

        const verifiedProgrammer = accounts[1];
        await this.verificatorInstance.addVerifiedProgrammer(verifiedProgrammer);

        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        try {
            // cause error because address should be a smart contract address, not a personal address
            await this.smartContractVerificatorInstance.sendSmartContractTest(accounts[42], true, {from: programmer});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although passed address is not a smart contract.");

        const notVerifiedProgrammer = accounts[2];
        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        try {
            // cause error because address should be a smart contract address, not a personal address
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: notVerifiedProgrammer});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although passed address is not a smart contract.");

        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: verifiedProgrammer}).then(async () => {
            assert.equal(1, (await this.smartContractVerificatorInstance.getTests({from: verifiedProgrammer})).length, "One test should have been added.")
        });

        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        try {
            // cause error because address should be a smart contract address, not a personal address
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: verifiedProgrammer});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although programmer already sent a test for this smart contract.");

        for (let i = 3; i < 7; i++) {
            assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
            const anotherProgrammer = accounts[i];
            await this.verificatorInstance.addVerifiedProgrammer(anotherProgrammer).then(async () => {
                await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: anotherProgrammer}).then(async () => {
                    assert.equal(i - 1, (await this.smartContractVerificatorInstance.getTests({from: anotherProgrammer})).length, "Another test should have been added.")
                });
            });
        }

        const anotherProgrammer = accounts[7];
        assert.equal(false, await this.smartContractVerificatorInstance.isTesterSpace(), "There should be no tester space.");
        await this.verificatorInstance.addVerifiedProgrammer(anotherProgrammer);
        try {
            // cause error because address should be a smart contract address, not a personal address
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: anotherProgrammer});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although test limit reached maximum of 5.");

    });

    it('should increase reward stake', async () => {
        // test reward stake wallet
        const payer = accounts[1];
        var BN = web3.utils.BN;
        var balanceBefore = await this.smartContractVerificatorInstance.getRewardAmount();
        await this.smartContractVerificatorInstance.increaseRewardStake({
            from: payer,
            value: 123456
        }).then(async () => {
            // added 2000610580000000000 automatically plus additional 123456
            assert.equal((new BN('2000610580000123456').add(balanceBefore)).toString(), (await this.smartContractVerificatorInstance.getRewardAmount()).toString(), "Should have 123456 more now.");
        });
    });

    it('should ', async () => {

    });
});
