const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const Verificator = artifacts.require("Verificator");
const MockSmartContractTest1 = artifacts.require("MockSmartContractTest1");
const MockSmartContractTest2 = artifacts.require("MockSmartContractTest2");
const MockSmartContractTest3 = artifacts.require("MockSmartContractTest3");
const MockSmartContractTest4 = artifacts.require("MockSmartContractTest4");
const MockSmartContractTest5 = artifacts.require("MockSmartContractTest5");
const MockSmartContractTest6 = artifacts.require("MockSmartContractTest6");
const MockSmartContractTest7 = artifacts.require("MockSmartContractTest7");

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
            await MockSmartContractTest6.deployed(),
            await MockSmartContractTest7.deployed()]
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
        assert.equal(1, (await this.smartContractVerificatorInstance.getTests({from: verifiedProgrammer})).length, "One test should have been added.");


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
        await this.smartContractVerificatorInstance.increaseRewardStake({from: payer, value: 123456789100});
        assert.equal((new BN('123456789100').add(balanceBefore)).toString(), (await this.smartContractVerificatorInstance.getRewardAmount()).toString(), "Should have 123456789100 more now.");
        await this.smartContractVerificatorInstance.increaseRewardStake({from: payer, value: 109876543210});
        assert.equal((new BN('233333332310')).toString(), (await this.smartContractVerificatorInstance.getRewardAmount()).toString(), "Should have 123456789100 + 109876543210 = 233333332310.");
    });

    it('should evaluate tests of smart contracts', async () => {
        await this.verificatorInstance.addSmartContractVerificator(this.smartContractVerificatorInstance.address);
        // tester accounts[8] to accounts[108]
        // rating only this.smartContractTests[0]
        for (let i = 10; i < 110; i++) {
            await this.verificatorInstance.addVerifiedProgrammer(accounts[i]);
            if (i < 28) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[0].address, 0, {from: accounts[i]});
            } else if (28 <= i && i < 80) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[0].address, 1, {from: accounts[i]});
            } else if (i >= 80) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[0].address, 2, {from: accounts[i]});
            }
        }
        for (let i = 10; i < 110; i++) {
            if (i < 28) {
                assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(accounts[i])).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
            } else if (28 <= i && i < 80) {
                assert.equal(11, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(accounts[i])).toNumber(), "Programmer should have rating INITIAL_START_POINTS (10) plus 1 for the swarm rating of 1.");
            } else if (i >= 80) {
                assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(accounts[i])).toNumber(), "Programmer should have only INITIAL_START_POINTS (10).");
            }
        }

        for (let i = 10; i < 110; i++) {
            if (i < 80) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[1].address, 0, {from: accounts[i]});
            } else if (80 <= i && i < 85) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[1].address, 1, {from: accounts[i]});
            } else if (i >= 85) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[1].address, 2, {from: accounts[i]});
            }
        }

        for (let i = 10; i < 110; i++) {
            if (i < 28) {
                assert.equal(11, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(accounts[i])).toNumber(), "Programmer should have only INITIAL_START_POINTS (10) plus 1 for the swarm rating of 0.");
            } else if (28 <= i && i < 80) {
                assert.equal(12, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(accounts[i])).toNumber(), "Programmer should have rating INITIAL_START_POINTS (10) plus 1 for the swarm rating of 1 plus 1 for the swarm rating of 0.");
            } else if (80 <= i) {
                assert.equal(10, (await this.verificatorInstance.getVerifiedProgrammerPoints.call(accounts[i])).toNumber(), "Programmer should have same points as above.");
            }
        }

        // should be enough space to push another two tests
        await this.verificatorInstance.addVerifiedProgrammer(accounts[8]);
        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[5].address, true, {from: accounts[8]});

        await this.verificatorInstance.addVerifiedProgrammer(accounts[9]);
        assert.isOk(await this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full.");
        await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTests[6].address, true, {from: accounts[9]});
    });

    it('should distribute reward to the 5 level 2 swarm testers', async () => {
        // accounts 8, 9, 4, 5, 6 are the writers of the tests
        let balanceAccount8Before = parseInt(await web3.eth.getBalance(accounts[8]));
        let balanceAccount9Before = parseInt(await web3.eth.getBalance(accounts[9]));
        let balanceAccount4Before = parseInt(await web3.eth.getBalance(accounts[4]));
        let balanceAccount5Before = parseInt(await web3.eth.getBalance(accounts[5]));
        let balanceAccount6Before = parseInt(await web3.eth.getBalance(accounts[6]));
        let balanceAccount111Before = parseInt(await web3.eth.getBalance(accounts[3]));
        let rewardAmount = parseInt((await this.smartContractVerificatorInstance.getRewardAmount()).toString());
        for (let i = 10; i < 110; i++) {
            if (i < 10) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[2].address, 0, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[3].address, 0, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[4].address, 0, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[5].address, 0, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[6].address, 0, {from: accounts[i]});
            } else if (10 <= i && i < 28) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[2].address, 1, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[3].address, 1, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[4].address, 1, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[5].address, 1, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[6].address, 1, {from: accounts[i]});
            } else if (i >= 28) {
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[2].address, 2, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[3].address, 2, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[4].address, 2, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[5].address, 2, {from: accounts[i]});
                await this.smartContractVerificatorInstance.evaluateTestOfSmartContract(this.smartContractTests[6].address, 2, {from: accounts[i]});
            }
        }

        let balanceAccount8 = parseInt(await web3.eth.getBalance(accounts[8]));
        let balanceAccount9 = parseInt(await web3.eth.getBalance(accounts[9]));
        let balanceAccount4 = parseInt(await web3.eth.getBalance(accounts[4]));
        let balanceAccount5 = parseInt(await web3.eth.getBalance(accounts[5]));
        let balanceAccount6 = parseInt(await web3.eth.getBalance(accounts[6]));
        let balanceAccount111 = parseInt(await web3.eth.getBalance(accounts[3]));
        /*
        console.log("SWARM LEVEL 2 TESTERS: " + (await this.smartContractVerificatorInstance.getSwarmLevelTwoTesters()).toString());
        console.log("ACTUAL: " + accounts[8] + ", " + accounts[9] + ", " + accounts[4] + ", " + accounts[5] +", "+ accounts[6]);
        console.log(balanceAccount8Before.toString() + " , AFTER: " + balanceAccount8.toString());
        console.log(balanceAccount9Before.toString() + " , AFTER: " + balanceAccount9.toString());
        console.log(balanceAccount4Before.toString() + " , AFTER: " + balanceAccount4.toString());
        console.log(balanceAccount5Before.toString() + " , AFTER: " + balanceAccount5.toString());
        console.log(balanceAccount6Before.toString() + " , AFTER: " + balanceAccount6.toString());
        console.log(balanceAccount111Before.toString() + " , AFTER: " + balanceAccount111.toString());
        console.log("REWARD: " + rewardAmount + ", REWARD FIFTH: " + parseInt(rewardAmount) / 5);
        */
        assert.ok((balanceAccount8Before) < (balanceAccount8), "Balance should be higher because of the reward");
        assert.ok((balanceAccount9Before) < (balanceAccount9), "Balance should be higher because of the reward");
        assert.ok((balanceAccount4Before) < (balanceAccount4), "Balance should be higher because of the reward");
        assert.ok((balanceAccount5Before) < (balanceAccount5), "Balance should be higher because of the reward");
        assert.ok((balanceAccount6Before) < (balanceAccount6), "Balance should be higher because of the reward");
        if (rewardAmount % 5 === 0) {
            let fifthReward = rewardAmount / 5;
            let gas = 3538;
            assert.equal((balanceAccount8Before) + (fifthReward) - gas, (balanceAccount8), "Balance should be the fifth reward higher.");
            assert.equal((balanceAccount9Before) + (fifthReward) - gas, (balanceAccount9), "Balance should be the fifth reward higher.");
            assert.equal((balanceAccount4Before) + (fifthReward) - gas, (balanceAccount4), "Balance should be the fifth reward higher.");
            assert.equal((balanceAccount5Before) + (fifthReward) - gas, (balanceAccount5), "Balance should be the fifth reward higher.");
            assert.equal((balanceAccount6Before) + (fifthReward) - gas, (balanceAccount6), "Balance should be the fifth reward higher.");
        } else {
            console.log("Can not be divided by 5.");
        }
    });
});
