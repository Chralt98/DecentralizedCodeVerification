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
});
