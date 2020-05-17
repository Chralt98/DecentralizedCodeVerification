const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const Verificator = artifacts.require("Verificator");
const MockSmartContractTest1 = artifacts.require("MockSmartContractTest1");
const MockSmartContractTest2 = artifacts.require("MockSmartContractTest2");
const MockSmartContractTest3 = artifacts.require("MockSmartContractTest3");
const MockSmartContractTest4 = artifacts.require("MockSmartContractTest4");
const MockSmartContractTest5 = artifacts.require("MockSmartContractTest5");
const MockSmartContractTest6 = artifacts.require("MockSmartContractTest6");

contract('SmartContractVerificator', (accounts) => {

    before(async () => {
        this.smartContractVerificatorInstance = await SmartContractVerificator.deployed();
        this.smartContractToVerify = await MockSmartContractToVerify.deployed();
        this.verificatorInstance = await Verificator.deployed();
        this.smartContractTests = [await MockSmartContractTest1.deployed(),
            await MockSmartContractTest2.deployed(),
            await MockSmartContractTest3.deployed(),
            await MockSmartContractTest4.deployed(),
            await MockSmartContractTest5.deployed(),
            await MockSmartContractTest6.deployed()]
    });

    it('should check smart contract to verify', async () => {
        assert.equal(await this.smartContractVerificatorInstance.getSmartContractToVerify(), this.smartContractToVerify.address, "Smart contract addresses should be equal.");
        assert(await this.smartContractVerificatorInstance.isSmartContractVerified() === false, "Smart contract should not be verified.");
        assert(await this.smartContractVerificatorInstance.getVerificationState() === "ACTIVE", "Smart contract should be active.");
    });

    it('should send smart contract test', async () => {
        const owner = accounts[0];
        await this.verificatorInstance.addVerifiedProgrammer(owner);
        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        try {
            // cause error because owner should not sent a test for his own contract
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[0].address, true, {from: owner});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although owner should not sent a test.");

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
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[0].address, true, {from: notVerifiedProgrammer});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although passed address is not a smart contract.");

        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[0].address, true, {from: verifiedProgrammer});
        assert.equal(1, (await this.smartContractVerificatorInstance.getTests({from: verifiedProgrammer})).length, "One test should have been added.")


        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        try {
            // cause error because address should be a smart contract address, not a personal address
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[1].address, true, {from: verifiedProgrammer});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although programmer already sent a test for this smart contract.");

        for (let i = 3; i < 7; i++) {
            assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
            const anotherProgrammer = accounts[i];
            await this.verificatorInstance.addVerifiedProgrammer(anotherProgrammer);
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[i - 2].address, true, {from: anotherProgrammer});
            assert.equal(i - 1, (await this.smartContractVerificatorInstance.getTests({from: anotherProgrammer})).length, "Another test should have been added.")
        }

        const anotherProgrammer = accounts[7];
        assert.equal(false, await this.smartContractVerificatorInstance.isTesterSpace(), "There should be no tester space.");
        await this.verificatorInstance.addVerifiedProgrammer(anotherProgrammer);
        try {
            // cause error because address should be a smart contract address, not a personal address
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[5].address, true, {from: anotherProgrammer});
        } catch (e) {
            var err = e;
        }
        assert.isOk(err instanceof Error, "Transaction was not reverted although test limit reached maximum of 5.");

    });

    it('should increase reward stake', async () => {
        // test reward stake
        const payer = accounts[1];
        let BN = web3.utils.BN;
        let balanceBefore = await this.smartContractVerificatorInstance.getRewardAmount();
        await this.smartContractVerificatorInstance.increaseRewardStake({from: payer, value: 123456});
        assert.equal((new BN('123456').add(balanceBefore)).toString(), (await this.smartContractVerificatorInstance.getRewardAmount()).toString(), "Should have 123456 more now.");
        await this.smartContractVerificatorInstance.increaseRewardStake({from: payer, value: 654321});
        assert.equal((new BN('777777')).toString(), (await this.smartContractVerificatorInstance.getRewardAmount()).toString(), "Should have 654321 + 123456 = 777777.");
    });

    it('should evaluate tests of smart contracts', async () => {
        await this.verificatorInstance.addSmartContractVerificator(this.smartContractVerificatorInstance.address);
        // tester accounts[8] to accounts[108]
        // rating only this.smartContractTests[0]
        var zeros = 0;
        var zeroReviewer = [];
        var ones = 0;
        var oneReviewer = [];
        var twos = 0;
        var twoReviewer = [];
        for (let i = 8; i < 108; i++) {
            let rand = Math.floor((Math.random() * 2));
            switch (rand) {
                case 0:
                    zeros++;
                    zeroReviewer.push(accounts[i]);
                    break;
                case 1:
                    ones++;
                    oneReviewer.push(accounts[i]);
                    break;
                case 2:
                    twos++;
                    twoReviewer.push(accounts[i]);
                    break;
            }
            await this.verificatorInstance.addVerifiedProgrammer(accounts[i]);
            await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[0].address, rand, {from: accounts[i]});
        }
        let swarm = -1;
        if (zeros > ones && zeros > twos) {
            swarm = 0;
        } else if (ones > zeros && ones > twos) {
            swarm = 1;
        } else if (twos > zeros && twos > ones) {
            swarm = 2;
        } else {
            // there is no majority, wait for the next reviewer
            console.log('no majority');
        }
        switch (swarm) {
            case 0:
                for (const programmer of zeroReviewer) {
                    assert.equal(11, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should've rating INITIAL_START_POINTS (10) plus 1 for the swarm rating of 0.");
                }
                for (const programmer of oneReviewer) {
                    assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
                }
                for (const programmer of twoReviewer) {
                    assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
                }
                break;
            case 1:
                for (const programmer of zeroReviewer) {
                    assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
                }
                for (const programmer of oneReviewer) {
                    assert.equal(11, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should've rating INITIAL_START_POINTS (10) plus 1 for the swarm rating of 1.");
                }
                for (const programmer of twoReviewer) {
                    assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
                }
                break;
            case 2:
                for (const programmer of zeroReviewer) {
                    assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
                }
                for (const programmer of oneReviewer) {
                    assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
                }
                for (const programmer of twoReviewer) {
                    assert.equal(11, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(programmer)).toNumber(), "Programmer should've rating INITIAL_START_POINTS (10) plus 1 for the swarm rating of 2.");
                }
                break;
            default:
                console.log("no majority!");
        }
    });
});
