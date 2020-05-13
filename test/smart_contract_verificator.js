const SmartContractVerificator = artifacts.require("SmartContractVerificator");
const MockSmartContractToVerify = artifacts.require("MockSmartContractToVerify");
const MockSmartContractTest = artifacts.require("MockSmartContractTest");
const Verificator = artifacts.require("Verificator");

contract('SmartContractVerificator', (accounts) => {
    var verificatorInstance;
    var smartContractVerificatorInstance;
    var smartContractToVerify;
    var smartContractTest;

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
        const programmer = accounts[2];
        await this.verificatorInstance.addVerifiedProgrammer(programmer).then(async () => {
            await this.smartContractVerificatorInstance.sendSmartContractTest(this.smartContractTest.address, true, {from: programmer}).then(async () => {
                console.log(this.smartContractTest.address);
                assert.isOk(this.smartContractVerificatorInstance.isTesterSpace(), "Tester space shouldn't be full");
                // TODO check if test is added:
                console.log(this.smartContractVerificatorInstance.getTests({from: programmer}));
                assert.isOk(this.smartContractVerificatorInstance.getTests({from: programmer}), "Test should be added.");
            });
        });
    });

    it('should increase reward stake', async () => {
        // test reward stake wallet
        const payer = accounts[1];
        await this.smartContractVerificatorInstance.getRewardAmount().then(async (balanceBefore) => {
            await this.smartContractVerificatorInstance.increaseRewardStake({
                from: payer,
                value: 1e18
            }).then(async () => {
                assert.equal(web3.utils.toBN(1e18 + balanceBefore), web3.utils.toBN(await this.smartContractVerificatorInstance.getRewardAmount()), "Should have 1 ether more now.");
            });
        });
    });
});
